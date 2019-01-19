require 'rails_helper'

describe 'Thumbnail' do
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

  describe 'Method "url"' do
    it 'returns valid url' do
      thumbnail = Thumbnail.new('an-object-key')
      expect(thumbnail.url).to eq('https://my-image-bucket.s3-ap-northeast-1.amazonaws.com/an-object-key/thumbnail.jpg')
    end
  end
end

describe 'Slide_on_Azure' do
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

  describe 'Method "url"' do
    it 'returns valid url' do
      thumbnail = Thumbnail.new('an-object-key')
      expect(thumbnail.url).to eq('https://azure_test.blob.core.windows.net/my-image-bucket/an-object-key/thumbnail.jpg')
    end
  end
end
