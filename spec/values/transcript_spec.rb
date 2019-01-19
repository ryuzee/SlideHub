require 'rails_helper'

describe 'Transcript' do
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

  describe 'Transcript' do
    it 'can be retrieved and put it into array' do
      allow_any_instance_of(Transcript).to receive(:url).and_return('http://www.example.com/transcript.txt')
      stub_request(:any, 'http://www.example.com/transcript.txt').to_return(
        body: 'a:1:{i:0;s:4:"Test";}',
        status: 200,
      )
      transcript = Transcript.new('an_object_key')
      expect(transcript.lines).to eq(['Test'])
      expect(transcript.exist?).to eq(true)
    end

    it 'can not be ritrieved because of 404' do
      allow_any_instance_of(Transcript).to receive(:url).and_return('http://www.example.com/transcript.txt')
      stub_request(:any, 'http://www.example.com/transcript.txt').to_return(
        status: 404,
      )
      transcript = Transcript.new('an_object_key')
      expect(transcript.lines).to eq([])
      expect(transcript.exist?).to eq(false)
    end

    it 'can be retrieved. however the result is empty' do
      allow_any_instance_of(Transcript).to receive(:url).and_return('http://www.example.com/transcript.txt')
      stub_request(:any, 'http://www.example.com/transcript.txt').to_return(
        body: 'a:1:{i:0;s:0:"";}',
        status: 200,
      )
      transcript = Transcript.new('an_object_key')
      expect(transcript.exist?).to eq(false)
    end
  end

  describe 'Method "url"' do
    it 'returns valid url' do
      transcript = Transcript.new('an-object-key')
      expect(transcript.url).to eq('https://my-image-bucket.s3-ap-northeast-1.amazonaws.com/an-object-key/transcript.txt')
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
      transcript = Transcript.new('an-object-key')
      expect(transcript.url).to eq('https://azure_test.blob.core.windows.net/my-image-bucket/an-object-key/transcript.txt')
    end
  end
end
