require 'rails_helper'

describe 'AWSConfig' do
  before do
    AWSConfig.configure do |config|
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

  describe 'resource_endpoint' do
    it 'return URL that includes image bucket name and region in Tokyo region' do
      expect(AWSConfig.resource_endpoint).to eq('https://my-image-bucket.s3-ap-northeast-1.amazonaws.com')
    end
    it 'return URL that includes image bucket name in us-east-1' do
      AWSConfig.configure do |config|
        config.region = 'us-east-1'
      end
      expect(AWSConfig.resource_endpoint).to eq('https://my-image-bucket.s3.amazonaws.com')
    end
    it 'return CDN URL' do
      AWSConfig.configure do |config|
        config.cdn_base_url = 'https://sushi.example.com'
      end
      expect(AWSConfig.resource_endpoint).to eq('https://sushi.example.com')
    end
    it 'return S3 bucket name when enabling static hosting (In this case, SSL can not be used.)' do
      AWSConfig.configure do |config|
        config.image_bucket_name = 'toro.example.com'
        config.use_s3_static_hosting = '1'
      end
      expect(AWSConfig.resource_endpoint).to eq('http://toro.example.com')
    end
  end

  describe 'upload_endpoint' do
    it 'return URL that includes bucket name and region in Tokyo region' do
      expect(AWSConfig.upload_endpoint).to eq('https://my-bucket.s3-ap-northeast-1.amazonaws.com')
    end
    it 'return URL that includes bucket name in us-east-1' do
      AWSConfig.configure do |config|
        config.region = 'us-east-1'
      end
      expect(AWSConfig.upload_endpoint).to eq('https://my-bucket.s3.amazonaws.com')
    end
  end

  describe 's3_host_name' do
    it 'return hostname that includes region in Tokyo region' do
      expect(AWSConfig.s3_host_name).to eq('s3-ap-northeast-1.amazonaws.com')
    end
    it 'return hostname that does not include region in us-east-1' do
      AWSConfig.configure do |config|
        config.region = 'us-east-1'
      end
      expect(AWSConfig.s3_host_name).to eq('s3.amazonaws.com')
    end
  end
end
