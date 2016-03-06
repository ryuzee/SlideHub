require 'rails_helper'
require 'spec_helper'
require 'digest/md5'

module Aws
  module SQS
    class DummyClient
      def send_message(params = {}, options = {})
        nil
      end

      def receive_message(params = {})
        []
      end

      def delete_message(params = {})
        Seahorse::Client::Response.new
      end

      def delete_message_batch(params = {})
        Aws::SQS::Types::DeleteMessageBatchResult.new
      end
    end

    module Types
      class DummyReceiveMessageResult
        def initialize
          @msg = []
          @msg.push(DummyMessage.new)
        end

        def messages
          @msg
        end
      end

      class DummyMessage
        attr_accessor :receipt_handle
      end
    end
  end

  module S3
    class DummyClient
      def put_object(params = {})
      end

      def get_object(params = {})
        filename = params[:response_target]
        File.open(filename, 'wb') { |f| f.write('hoge') }
      end

      def delete_objects(params = {})
      end

      def list_objects(params = {})
        Types::DummyListObjectOutput.new
      end
    end

    class DummyPresigner
      def presigned_url(param1, params = {})
        'https://signed.example.com'
      end
    end

    module Types
      class DummyListObjectOutput
        def initialize
          @contents = []
          obj = Aws::S3::Types::Object.new
          obj.key = 'hoge'
          @contents.push(obj)
        end

        attr_reader :contents
      end
    end
  end
end

describe 'AWSEngine' do
  before do
    AWSEngine.configure do |config|
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
      expect(AWSEngine.resource_endpoint).to eq('https://my-image-bucket.s3-ap-northeast-1.amazonaws.com')
    end
    it 'return URL that includes image bucket name in us-east-1' do
      AWSEngine.configure do |config|
        config.region = 'us-east-1'
      end
      expect(AWSEngine.resource_endpoint).to eq('https://my-image-bucket.s3.amazonaws.com')
    end
    it 'return CDN URL' do
      AWSEngine.configure do |config|
        config.cdn_base_url = 'https://sushi.example.com'
      end
      expect(AWSEngine.resource_endpoint).to eq('https://sushi.example.com')
    end
    it 'return S3 bucket name when enabling static hosting (In this case, SSL can not be used.)' do
      AWSEngine.configure do |config|
        config.image_bucket_name = 'toro.example.com'
        config.use_s3_static_hosting = '1'
      end
      expect(AWSEngine.resource_endpoint).to eq('http://toro.example.com')
    end
  end

  describe 'upload_endpoint' do
    it 'return URL that includes bucket name and region in Tokyo region' do
      expect(AWSEngine.upload_endpoint).to eq('https://my-bucket.s3-ap-northeast-1.amazonaws.com')
    end
    it 'return URL that includes bucket name in us-east-1' do
      AWSEngine.configure do |config|
        config.region = 'us-east-1'
      end
      expect(AWSEngine.upload_endpoint).to eq('https://my-bucket.s3.amazonaws.com')
    end
  end

  describe 's3_host_name' do
    it 'return hostname that includes region in Tokyo region' do
      expect(AWSEngine.s3_host_name).to eq('s3-ap-northeast-1.amazonaws.com')
    end
    it 'return hostname that does not include region in us-east-1' do
      AWSEngine.configure do |config|
        config.region = 'us-east-1'
      end
      expect(AWSEngine.s3_host_name).to eq('s3.amazonaws.com')
    end
  end

  describe 'get_signing_key' do
    it 'returns true' do
      expected = 'a8a38db0c44e3f2b269d6468dbbb4c55'
      expect(Digest::MD5.hexdigest(AWSEngine.get_signing_key('20150101', 'ap-northeast-1', 's3', 'abcde'))).to eq(expected.to_s)
    end
  end

  describe 'populate_policy' do
    it 'returns array' do
      base_time = Time.utc(2016, 1, 1, 23, 59, 59, 0)
      access_id = 'AKIHOGEHOGE'
      secret_key = 'Secret'
      security_token = ''
      region = 'ap-northeast-1'
      bucket_name = 'sushi'
      value = AWSEngine.populate_policy(base_time, access_id, secret_key, security_token, region, bucket_name)
      expect(value['signature']).to eq('d3737356a01471adab35e87d768d8d23af17d3e30b0d66b08c9037447271fb93')
      expect(value['date_ymd']).to eq('20160101')
      expect(value['date_gm']).to eq('20160101T235959Z')
      p  = 'eyJleHBpcmF0aW9uIjoiMjAxNi0wMS0wMlQwMTo1OTo1OVoiLCJjb25kaXRp'
      p += 'b25zIjpbeyJidWNrZXQiOiJzdXNoaSJ9LFsic3RhcnRzLXdpdGgiLCIka2V5'
      p += 'IiwiIl0seyJhY2wiOiJwdWJsaWMtcmVhZCJ9LHsic3VjY2Vzc19hY3Rpb25f'
      p += 'c3RhdHVzIjoiMjAxIn0sWyJzdGFydHMtd2l0aCIsIiRDb250ZW50LVR5cGUi'
      p += 'LCJhcHBsaWNhdGlvbi9vY3RldHN0cmVhbSJdLHsieC1hbXotbWV0YS11dWlk'
      p += 'IjoiMTQzNjUxMjM2NTEyNzQifSxbInN0YXJ0cy13aXRoIiwiJHgtYW16LW1l'
      p += 'dGEtdGFnIiwiIl0seyJ4LWFtei1jcmVkZW50aWFsIjoiQUtJSE9HRUhPR0Uv'
      p += 'MjAxNjAxMDEvYXAtbm9ydGhlYXN0LTEvczMvYXdzNF9yZXF1ZXN0In0seyJ4'
      p += 'LWFtei1hbGdvcml0aG0iOiJBV1M0LUhNQUMtU0hBMjU2In0seyJ4LWFtei1k'
      p += 'YXRlIjoiMjAxNjAxMDFUMjM1OTU5WiJ9XX0='
      expect(value['base64_policy']).to eq(p)
    end
  end

  describe 'SQS' do
    before do
      allow(Aws::SQS::Client).to receive(:new).and_return(Aws::SQS::DummyClient.new)
    end

    it 'succeeds to send message' do
      expect(AWSEngine.send_message('hoge')).to eq(nil)
    end

    it 'succeeds to receive message' do
      expect(AWSEngine.receive_message(10)).to eq([])
    end

    it 'succeeds to return correct status of the existence of a message' do
      expect(AWSEngine.message_exist?(nil)).to eq(false)
      expect(AWSEngine.message_exist?(Aws::SQS::Types::DummyReceiveMessageResult.new)).to eq(true)
    end

    it 'succeeds to delete message' do
      expect(AWSEngine.delete_message(Aws::SQS::Types::DummyMessage.new).class.name).to eq('Seahorse::Client::Response')
    end

    it 'succeeds to delete messages all at once' do
      expect(AWSEngine.batch_delete([Aws::SQS::Types::DummyMessage.new]).class.name).to eq('Aws::SQS::Types::DeleteMessageBatchResult')
    end
  end

  describe 'S3' do
    before do
      allow(Aws::S3::Client).to receive(:new).and_return(Aws::S3::DummyClient.new)
      allow(Aws::S3::Presigner).to receive(:new).and_return(Aws::S3::DummyPresigner.new)
    end

    it 'succeeds to upload files' do
      files = []
      Tempfile.create('foo') do |f|
        files.push(f.path)
        puts files.inspect
        expect(AWSEngine.upload_files('container', files, 'test').class.name).to eq('Array')
      end
    end

    it 'succeeds to get file list' do
      expect(AWSEngine.get_file_list('container', 'prefix').class.name).to eq('Array')
    end

    it 'succeeds to save file' do
      Dir.mktmpdir do |dir|
        destination = "#{dir}/#{SecureRandom.hex}"
        AWSEngine.save_file('container', 'key', destination)
        expect(File.exist?(destination)).to eq(true)
      end
    end

    it 'succeeds to delete files and sildes' do
      expect(AWSEngine.delete_slide('')).to eq(false)
      expect(AWSEngine.delete_slide('hoge')).to eq(true)
      expect(AWSEngine.delete_generated_files('')).to eq(false)
      expect(AWSEngine.delete_generated_files('hoge')).to eq(true)
    end

    it 'succeeds to get slide download url' do
      expect(AWSEngine.get_slide_download_url('myblob')).to eq('https://signed.example.com')
    end
  end
end
