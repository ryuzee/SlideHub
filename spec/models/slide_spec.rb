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
#  modified_at    :datetime
#  object_key     :string(255)      default("")
#  extension      :string(10)       default(""), not null
#  convert_status :integer          default(0)
#  total_view     :integer          default(0), not null
#  page_view      :integer          default(0)
#  download_count :integer          default(0), not null
#  embedded_view  :integer          default(0), not null
#  num_of_pages   :integer          default(0)
#  comments_count :integer          default(0), not null
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

  describe 'Method "thumbnail_url"' do
    it 'is valid' do
      FactoryBot.create(:slide)
      object_key = Slide.find(1).object_key
      expect(Slide.find(1).thumbnail_url).to eq("https://my-image-bucket.s3-ap-northeast-1.amazonaws.com/#{object_key}/thumbnail.jpg")
    end
  end

  describe 'Transcript' do
    it 'can be retrieved and put it into array' do
      allow_any_instance_of(Slide).to receive(:transcript_url).and_return('http://www.example.com/transcript.txt')
      stub_request(:any, 'http://www.example.com/transcript.txt').to_return(
        body: 'a:1:{i:0;s:4:"Test";}',
        status: 200,
      )
      FactoryBot.create(:slide)
      slide = Slide.find(1)
      expect(slide.transcript).to eq(['Test'])
      expect(slide.transcript_exist?).to eq(true)
    end

    it 'can not be ritrieved because of 404' do
      allow_any_instance_of(Slide).to receive(:transcript_url).and_return('http://www.example.com/transcript.txt')
      stub_request(:any, 'http://www.example.com/transcript.txt').to_return(
        status: 404,
      )
      FactoryBot.create(:slide)
      slide = Slide.find(1)
      expect(slide.transcript).to eq([])
      expect(slide.transcript_exist?).to eq(false)
    end

    it 'can be retrieved. however the result is empty' do
      allow_any_instance_of(Slide).to receive(:transcript_url).and_return('http://www.example.com/transcript.txt')
      stub_request(:any, 'http://www.example.com/transcript.txt').to_return(
        body: 'a:1:{i:0;s:0:"";}',
        status: 200,
      )
      FactoryBot.create(:slide)
      slide = Slide.find(1)
      expect(slide.transcript_exist?).to eq(false)
    end
  end

  describe 'Method "transcript_url"' do
    it 'returns valid url' do
      FactoryBot.create(:slide)
      object_key = Slide.find(1).object_key
      expect(Slide.find(1).transcript_url).to eq("https://my-image-bucket.s3-ap-northeast-1.amazonaws.com/#{object_key}/transcript.txt")
    end
  end

  describe 'Method "page_list_url"' do
    it 'returns valid url' do
      FactoryBot.create(:slide)
      object_key = Slide.find(1).object_key
      expect(Slide.find(1).page_list_url).to eq("https://my-image-bucket.s3-ap-northeast-1.amazonaws.com/#{object_key}/list.json")
    end
  end

  describe 'Method "page_list"' do
    it 'returns page list (1 page)' do
      FactoryBot.create(:slide)
      object_key = Slide.find(1).object_key
      expect(Slide.find(1).page_list).to eq(["#{object_key}/slide-1.jpg"])
    end

    it 'returns page list (10 page)' do
      FactoryBot.create(:slide)
      slide = Slide.where('slides.id = ?', 1).first
      object_key = slide.object_key
      slide.num_of_pages = 10
      slide.save
      expected = ["#{object_key}/slide-01.jpg", "#{object_key}/slide-02.jpg", "#{object_key}/slide-03.jpg",
                  "#{object_key}/slide-04.jpg", "#{object_key}/slide-05.jpg", "#{object_key}/slide-06.jpg",
                  "#{object_key}/slide-07.jpg", "#{object_key}/slide-08.jpg", "#{object_key}/slide-09.jpg", "#{object_key}/slide-10.jpg"]
      expect(Slide.find(1).page_list).to eq(expected)
    end
  end
end

describe 'Slide_on_Azure' do
  let!(:default_user) { create(:default_user) }
  let!(:default_category) { create(:default_category) }

  before do
    CloudConfig.class_eval { remove_const(:SERVICE) }
    CloudConfig::SERVICE = SlideHub::Cloud::Engine::Azure
    SlideHub::Cloud::Engine::Azure.configure do |config|
      config.bucket_name = 'my-bucket'
      config.image_bucket_name = 'my-image-bucket'
      config.cdn_base_url = ''
      config.queue_name = 'my-queue'
      config.azure_storage_account_name = 'azure_test'
      config.azure_storage_access_key = 'azure_test_key'
    end
  end

  describe 'Method "thumbnail_url"' do
    it 'is valid' do
      FactoryBot.create(:slide)
      object_key = Slide.find(1).object_key
      expect(Slide.find(1).thumbnail_url).to eq("https://azure_test.blob.core.windows.net/my-image-bucket/#{object_key}/thumbnail.jpg")
    end
  end

  describe 'Method "transcript_url"' do
    it 'returns valid url' do
      FactoryBot.create(:slide)
      object_key = Slide.find(1).object_key
      expect(Slide.find(1).transcript_url).to eq("https://azure_test.blob.core.windows.net/my-image-bucket/#{object_key}/transcript.txt")
    end
  end

  describe 'Method "page_list_url"' do
    it 'returns valid url' do
      FactoryBot.create(:slide)
      object_key = Slide.find(1).object_key
      expect(Slide.find(1).page_list_url).to eq("https://azure_test.blob.core.windows.net/my-image-bucket/#{object_key}/list.json")
    end
  end
end
