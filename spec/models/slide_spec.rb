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
  let!(:success_data) do { user_id: default_user.id, name: 'dummy', description: 'dummy', object_key: 'dummy', category_id: default_category.id } end

  before do
    CloudConfig.class_eval { remove_const(:PROVIDER_ENGINE) }
    CloudConfig::PROVIDER_ENGINE = SlideHub::Cloud::Engine::AWS
    CloudHelpers.switch_to_aws
  end

  describe 'Creating "Slide" model' do

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
      slide = FactoryBot.create(:slide)
      object_key = Slide.find(slide.id).object_key
      Slide.update_after_convert(object_key, 'pdf', 100)
      expect(Slide.find(slide.id).convert_status).to eq('converted')
      expect(Slide.find(slide.id).extension).to eq('.pdf')
      expect(Slide.find(slide.id).num_of_pages).to eq(100)
    end

    it 'does not do anything' do
      status = Slide.update_after_convert('aaa', 'pdf', 100)
      expect(status).to eq(false)
    end
  end

  describe 'Method "record_access"' do
    it 'increments page_view"' do
      slide = FactoryBot.create(:slide)
      page_view = slide.page_view
      total_view = slide.total_view
      slide.record_access(:page_view)
      expect(Slide.find(slide.id).page_view).to eq(page_view + 1)
      expect(Slide.find(slide.id).total_view).to eq(total_view + 1)
    end

    it 'increments embedded_view' do
      slide = FactoryBot.create(:slide)
      embedded_view = slide.embedded_view
      total_view = slide.total_view
      slide.record_access(:embedded_view)
      expect(Slide.find(slide.id).embedded_view).to eq(embedded_view + 1)
      expect(Slide.find(slide.id).total_view).to eq(total_view + 1)
    end
  end
end
