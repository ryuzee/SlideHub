require 'rails_helper'
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
      def put_object(params = {}); end

      def get_object(params = {})
        filename = params[:response_target]
        File.binwrite(filename, 'hoge')
      end

      def delete_objects(params = {}); end

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

  module EC2
    class DummyClient
      class DummyCredential
        class DummyCredentialCredential
          def access_key_id
            'iam_access_key'
          end

          def secret_access_key
            'iam_secret_access_key'
          end

          def session_token
            'iam_session_token'
          end
        end

        def credentials
          DummyCredentialCredential.new
        end
      end

      def config
        { credentials: DummyCredential.new }
      end
    end
  end
end

describe 'SlideHub::Cloud::Engine::AWS' do
  before do
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

  describe 'resource_endpoint' do
    it 'return URL that includes image bucket name and region in Tokyo region' do
      expect(SlideHub::Cloud::Engine::AWS.resource_endpoint).to eq('https://my-image-bucket.s3-ap-northeast-1.amazonaws.com')
    end
    it 'return URL that includes image bucket name in us-east-1' do
      SlideHub::Cloud::Engine::AWS.configure do |config|
        config.region = 'us-east-1'
      end
      expect(SlideHub::Cloud::Engine::AWS.resource_endpoint).to eq('https://my-image-bucket.s3.amazonaws.com')
    end
    it 'return CDN URL' do
      SlideHub::Cloud::Engine::AWS.configure do |config|
        config.cdn_base_url = 'https://sushi.example.com'
      end
      expect(SlideHub::Cloud::Engine::AWS.resource_endpoint).to eq('https://sushi.example.com')
    end
    it 'return S3 bucket name when enabling static hosting (In this case, SSL can not be used.)' do
      SlideHub::Cloud::Engine::AWS.configure do |config|
        config.image_bucket_name = 'toro.example.com'
        config.use_s3_static_hosting = '1'
      end
      expect(SlideHub::Cloud::Engine::AWS.resource_endpoint).to eq('http://toro.example.com')
    end
  end

  describe 'upload_endpoint' do
    it 'return URL that includes bucket name and region in Tokyo region' do
      expect(SlideHub::Cloud::Engine::AWS.upload_endpoint).to eq('https://my-bucket.s3-ap-northeast-1.amazonaws.com')
    end
    it 'return URL that includes bucket name in us-east-1' do
      SlideHub::Cloud::Engine::AWS.configure do |config|
        config.region = 'us-east-1'
      end
      expect(SlideHub::Cloud::Engine::AWS.upload_endpoint).to eq('https://my-bucket.s3.amazonaws.com')
    end
  end

  describe 's3_host_name' do
    it 'return hostname that includes region in Tokyo region' do
      expect(SlideHub::Cloud::Engine::AWS.s3_host_name).to eq('s3-ap-northeast-1.amazonaws.com')
    end
    it 'return hostname that does not include region in us-east-1' do
      SlideHub::Cloud::Engine::AWS.configure do |config|
        config.region = 'us-east-1'
      end
      expect(SlideHub::Cloud::Engine::AWS.s3_host_name).to eq('s3.amazonaws.com')
    end
  end

  describe 'get_signing_key' do
    it 'returns true' do
      expected = 'a8a38db0c44e3f2b269d6468dbbb4c55'
      expect(Digest::MD5.hexdigest(SlideHub::Cloud::Engine::AWS.get_signing_key('20150101', 'ap-northeast-1', 's3', 'abcde'))).to eq(expected.to_s)
    end
  end

  describe 'create_policy_proc' do
    it 'returns policy' do
      base_time = Time.utc(2016, 1, 1, 23, 59, 59, 0)
      value = SlideHub::Cloud::Engine::AWS.create_policy_proc(base_time)
      expect(value['signature']).to eq('af5e492d88ee5c6c50cd576552b8cbd6c0824281b9967df06c107422da930b6d')
      expect(value['date_ymd']).to eq('20160101')
      expect(value['date_gm']).to eq('20160101T235959Z')
      expected_policy = 'eyJleHBpcmF0aW9uIjoiMjAxNi0wMS0wMlQwMTo1OTo1OVoiLCJjb25kaXRp'
      expected_policy += 'b25zIjpbeyJidWNrZXQiOiJteS1idWNrZXQifSxbInN0YXJ0cy13aXRoIiwi'
      expected_policy += 'JGtleSIsIiJdLHsiYWNsIjoicHVibGljLXJlYWQifSx7InN1Y2Nlc3NfYWN0'
      expected_policy += 'aW9uX3N0YXR1cyI6IjIwMSJ9LFsic3RhcnRzLXdpdGgiLCIkQ29udGVudC1U'
      expected_policy += 'eXBlIiwiYXBwbGljYXRpb24vb2N0ZXRzdHJlYW0iXSx7IngtYW16LW1ldGEt'
      expected_policy += 'dXVpZCI6IjE0MzY1MTIzNjUxMjc0In0sWyJzdGFydHMtd2l0aCIsIiR4LWFt'
      expected_policy += 'ei1tZXRhLXRhZyIsIiJdLHsieC1hbXotY3JlZGVudGlhbCI6ImF3c19hY2Nl'
      expected_policy += 'c3NfaWQvMjAxNjAxMDEvYXAtbm9ydGhlYXN0LTEvczMvYXdzNF9yZXF1ZXN0'
      expected_policy += 'In0seyJ4LWFtei1hbGdvcml0aG0iOiJBV1M0LUhNQUMtU0hBMjU2In0seyJ4'
      expected_policy += 'LWFtei1kYXRlIjoiMjAxNjAxMDFUMjM1OTU5WiJ9XX0='
      expect(value['base64_policy']).to eq(expected_policy)
    end
  end

  describe 'SQS' do
    before do
      allow(Aws::SQS::Client).to receive(:new).and_return(Aws::SQS::DummyClient.new)
    end

    it 'succeeds to send message' do
      expect(SlideHub::Cloud::Engine::AWS.send_message('hoge')).to eq(nil)
    end

    it 'succeeds to receive message' do
      expect(SlideHub::Cloud::Engine::AWS.receive_message(10).class.name).to eq('SlideHub::Cloud::Queue::Response')
    end

    it 'succeeds to delete message' do
      msg = SlideHub::Cloud::Queue::Message.new(1, 'text', 'handle')
      expect(SlideHub::Cloud::Engine::AWS.delete_message(msg).class.name).to eq('Seahorse::Client::Response')
    end

    it 'succeeds to delete messages all at once' do
      msg = []
      msg.push SlideHub::Cloud::Queue::Message.new(1, 'text', 'handle')
      expect(SlideHub::Cloud::Engine::AWS.batch_delete(msg).class.name).to eq('Seahorse::Client::Response')
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
        expect(SlideHub::Cloud::Engine::AWS.upload_files('container', files, 'test').class.name).to eq('Array')
      end
    end

    it 'succeeds to get file list' do
      expect(SlideHub::Cloud::Engine::AWS.get_file_list('container', 'prefix').class.name).to eq('Array')
    end

    it 'succeeds to save file' do
      Dir.mktmpdir do |dir|
        destination = "#{dir}/#{SecureRandom.hex}"
        expect(SlideHub::Cloud::Engine::AWS.save_file('container', 'key', destination)).to eq(true)
        expect(File.exist?(destination)).to eq(true)
        expect(SlideHub::Cloud::Engine::AWS.save_file('container', 'key', nil)).to eq(false)
      end
    end

    it 'succeeds to delete files and sildes' do
      expect(SlideHub::Cloud::Engine::AWS.delete_slide('')).to eq(false)
      expect(SlideHub::Cloud::Engine::AWS.delete_slide('hoge')).to eq(true)
      expect(SlideHub::Cloud::Engine::AWS.delete_generated_files('')).to eq(false)
      expect(SlideHub::Cloud::Engine::AWS.delete_generated_files('hoge')).to eq(true)
    end

    it 'succeeds to get slide download url' do
      expect(SlideHub::Cloud::Engine::AWS.get_slide_download_url('myblob')).to eq('https://signed.example.com')
    end
  end
end

describe 'SlideHub::Cloud::Engine::AWS without access_id and secret_key' do
  before do
    SlideHub::Cloud::Engine::AWS.configure do |config|
      config.region = 'ap-northeast-1'
      config.aws_access_id = nil
      config.aws_secret_key = nil
      config.bucket_name = 'my-bucket'
      config.image_bucket_name = 'my-image-bucket'
      config.sqs_url = 'https://www.ryuzee.com'
      config.use_s3_static_hosting = '0'
      config.cdn_base_url = ''
    end
  end

  describe 'create_policy_proc' do
    it 'returns policy' do
      allow(Aws::EC2::Client).to receive(:new).and_return(Aws::EC2::DummyClient.new)
      base_time = Time.utc(2016, 1, 1, 23, 59, 59, 0)
      value = SlideHub::Cloud::Engine::AWS.create_policy_proc(base_time)
      expect(value['signature']).to eq('2a6bee16e76dc0ff59eb057922a305b118ef89cff677507181e54ea65c779875')
      expect(value['date_ymd']).to eq('20160101')
      expect(value['date_gm']).to eq('20160101T235959Z')
      expected_policy = 'eyJleHBpcmF0aW9uIjoiMjAxNi0wMS0wMlQwMTo1OTo1OVoiLCJjb25kaXRp'
      expected_policy += 'b25zIjpbeyJidWNrZXQiOiJteS1idWNrZXQifSxbInN0YXJ0cy13aXRoIiwi'
      expected_policy += 'JGtleSIsIiJdLHsiYWNsIjoicHVibGljLXJlYWQifSx7InN1Y2Nlc3NfYWN0'
      expected_policy += 'aW9uX3N0YXR1cyI6IjIwMSJ9LFsic3RhcnRzLXdpdGgiLCIkQ29udGVudC1U'
      expected_policy += 'eXBlIiwiYXBwbGljYXRpb24vb2N0ZXRzdHJlYW0iXSx7IngtYW16LW1ldGEt'
      expected_policy += 'dXVpZCI6IjE0MzY1MTIzNjUxMjc0In0sWyJzdGFydHMtd2l0aCIsIiR4LWFt'
      expected_policy += 'ei1tZXRhLXRhZyIsIiJdLHsieC1hbXotY3JlZGVudGlhbCI6ImlhbV9hY2Nl'
      expected_policy += 'c3Nfa2V5LzIwMTYwMTAxL2FwLW5vcnRoZWFzdC0xL3MzL2F3czRfcmVxdWVz'
      expected_policy += 'dCJ9LHsieC1hbXotYWxnb3JpdGhtIjoiQVdTNC1ITUFDLVNIQTI1NiJ9LHsi'
      expected_policy += 'eC1hbXotZGF0ZSI6IjIwMTYwMTAxVDIzNTk1OVoifSx7IngtYW16LXNlY3Vy'
      expected_policy += 'aXR5LXRva2VuIjoiaWFtX3Nlc3Npb25fdG9rZW4ifV19'
      expect(value['base64_policy']).to eq(expected_policy)
    end
  end
end
