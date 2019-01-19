# == Schema Information
#
# Table name: slides
#
#  id             :integer          not null, primary key
#  user_id        :integer          not null
#  name           :string(255)      not null
#  description    :text(65535)      not null
#  downloadable   :boolean          default(FALSE), not null
#  category_id    :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime
#  object_key     :string(255)      default("")
#  extension      :string(10)       default(""), not null
#  convert_status :integer          default("not_converted")
#  total_view     :integer          default(0), not null
#  page_view      :integer          default(0)
#  download_count :integer          default(0), not null
#  embedded_view  :integer          default(0), not null
#  num_of_pages   :integer          default(0)
#  comments_count :integer          default(0), not null
#  private        :boolean          default(FALSE), not null
#

require 'rails_helper'

describe 'Slide' do
  let!(:default_user) { create(:default_user) }
  let!(:default_category) { create(:default_category) }

  before do
    CloudConfig.class_eval { remove_const(:SERVICE) }
    CloudConfig::SERVICE = SlideHub::Cloud::Engine::AWS
    SlideHub::Cloud::Engine::AWS.configure do |config|
      config.region = 'ap-northeast-1'
      config.aws_access_id = 'aws_access_id'
      config.aws_secret_key = 'aws_secret_key'
      config.bucket_name = 'my-bucket'
      config.image_bucket_name = 'my-image-bucket'
      config.sqs_url = 'https://www.ryuzee.com'
      config.use_s3_static_hosting = '0'
      config.cdn_base_url = ''
    end
  end

  describe 'Creating "Slide" model' do
    success_data = { user_id: 1, name: 'dummy', description: 'dummy', object_key: 'dummy', category_id: 1 }

    it 'is valid with user_id, name, description, object_key and category' do
      slide = Slide.new(success_data)
      expect(slide.valid?).to eq(true)
    end

    it 'is invalid without name' do
      data = success_data.dup
      data.delete(:name)
      slide = Slide.new(data)
      expect(slide.valid?).to eq(false)
    end

    it 'is invalid without description' do
      data = success_data.dup
      data.delete(:description)
      slide = Slide.new(data)
      expect(slide.valid?).to eq(false)
    end

    it 'is invalid without object_key' do
      data = success_data.dup
      data.delete(:object_key)
      slide = Slide.new(data)
      expect(slide.valid?).to eq(false)
    end

    it 'is invalid without category' do
      data = success_data.dup
      data.delete(:category_id)
      slide = Slide.new(data)
      expect(slide.valid?).to eq(false)
    end

    it 'is invalid without user' do
      data = success_data.dup
      data.delete(:user_id)
      slide = Slide.new(data)
      expect(slide.valid?).to eq(false)
    end
  end

  describe 'Method "update_after_convert"' do
    it 'updates the convert status to "converted"' do
      FactoryBot.create(:slide)
      object_key = Slide.find(1).object_key
      Slide.update_after_convert(object_key, 'pdf', 100)
      expect(Slide.find(1).convert_status).to eq('converted')
      expect(Slide.find(1).extension).to eq('.pdf')
      expect(Slide.find(1).num_of_pages).to eq(100)
    end

    it 'does not do anything' do
      status = Slide.update_after_convert('aaa', 'pdf', 100)
      expect(status).to eq(false)
    end
  end

  describe 'Method "record_access"' do
    it 'increments page_view"' do
      FactoryBot.create(:slide)
      slide = Slide.find(1)
      page_view = slide.page_view
      total_view = slide.total_view
      slide.record_access(:page_view)
      expect(Slide.find(1).page_view).to eq(page_view + 1)
      expect(Slide.find(1).total_view).to eq(total_view + 1)
    end

    it 'increments embedded_view' do
      FactoryBot.create(:slide)
      slide = Slide.find(1)
      embedded_view = slide.embedded_view
      total_view = slide.total_view
      slide.record_access(:embedded_view)
      expect(Slide.find(1).embedded_view).to eq(embedded_view + 1)
      expect(Slide.find(1).total_view).to eq(total_view + 1)
    end
  end
end
