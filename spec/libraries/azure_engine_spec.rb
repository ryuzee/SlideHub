require 'rails_helper'
require 'digest/md5'
require 'tempfile'
require 'securerandom'
require 'tmpdir'
require 'uri'

module Azure
  module Queue
    class DummyQueueService
      def create_message(queue_name, message)
        nil
      end

      def list_messages(queue_name, timeout, options = {})
        message = Entity::Queue::DummyMessage.new
        [message]
      end

      def create_queue(queue_name)
        nil
      end

      def delete_message(queue_name, message_object_id, message_object_pop_receipt)
        nil
      end
    end
  end

  module Entity
    module Queue
      class DummyMessage
        attr_accessor :id
        attr_accessor :message_text
        attr_accessor :pop_receipt

        def initialize
          @id = 1
          @pop_receipt = ''
          @message_text = ''
        end
      end
    end
  end

  module Blob
    class DummyBlobObject
      def name
        'dummy'
      end
    end

    class DummyBlobService
      def create_block_blob(container, key, content, options = {})
        nil
      end

      def list_blobs(container, options = {})
        result = []
        result.push(Azure::Blob::DummyBlobObject.new)
        result
      end

      def get_blob(container, key)
        return nil, 'hoge'
      end

      def delete_blob(container, key)
        nil
      end

      def generate_uri(uri, options = {})
        URI('http://www.example.com')
      end
    end
  end

  module Storage
    module Core
      module Auth
        class DummySharedAccessSignature
          def signed_uri(a, b, c)
            'https://signed.example.com'
          end
        end
      end
    end
  end
end

describe 'SlideHub::Cloud::Engine::Azure' do
  before do
    SlideHub::Cloud::Engine::Azure.configure do |config|
      config.bucket_name = 'my-bucket'
      config.image_bucket_name = 'my-image-bucket'
      config.cdn_base_url = ''
      config.queue_name = 'my-queue'
      config.azure_storage_access_key = 'azure_storage_access_key'
      config.azure_storage_account_name = 'azure_storage_account_name'
    end
  end

  describe 'resource_endpoint' do
    it 'return URL that includes image bucket name' do
      expect(SlideHub::Cloud::Engine::Azure.resource_endpoint).to eq('https://azure_storage_account_name.blob.core.windows.net/my-image-bucket')
    end
    it 'return CDN URL' do
      SlideHub::Cloud::Engine::Azure.configure do |config|
        config.cdn_base_url = 'https://sushi.example.com'
      end
      expect(SlideHub::Cloud::Engine::Azure.resource_endpoint).to eq('https://sushi.example.com/my-image-bucket')
    end
  end

  describe 'upload_endpoint' do
    it 'return URL that includes bucket name' do
      expect(SlideHub::Cloud::Engine::Azure.upload_endpoint).to eq('https://azure_storage_account_name.blob.core.windows.net/my-bucket')
    end
  end

  describe 'queue_endpoint' do
    it 'return URL that specifies queue endpoint' do
      expect(SlideHub::Cloud::Engine::Azure.queue_endpoint).to eq('https://azure_storage_account_name.queue.core.windows.net/')
    end
  end

  describe 'Blob Queue' do
    before do
      allow_any_instance_of(Azure::ClientServices).to receive(:queues).and_return(Azure::Queue::DummyQueueService.new)
    end

    it 'succeeds to send message' do
      expect(SlideHub::Cloud::Engine::Azure.send_message('hoge')).to eq(nil)
    end

    it 'succeeds to receive message' do
      expect(SlideHub::Cloud::Engine::Azure.receive_message(10).class.name).to eq('SlideHub::Cloud::Queue::Response')
      expect(SlideHub::Cloud::Engine::Azure.receive_message(10).exist?).to eq(true)
    end

    it 'succeeds to delete message' do
      msg = SlideHub::Cloud::Queue::Message.new(1, 'text', 'handle')
      expect(SlideHub::Cloud::Engine::Azure.delete_message(msg).class.name).to eq('NilClass')
    end

    it 'succeeds to delete messages all at once' do
      msg = []
      msg.push SlideHub::Cloud::Queue::Message.new(1, 'text', 'handle')
      expect(SlideHub::Cloud::Engine::Azure.batch_delete(msg).class.name).to eq('NilClass')
    end
  end

  describe 'Blob Storage' do
    before do
      allow(Azure::Blob::BlobService).to receive(:new).and_return(Azure::Blob::DummyBlobService.new)
      allow(Azure::Storage::Core::Auth::SharedAccessSignature).to receive(:new).and_return(Azure::Storage::Core::Auth::DummySharedAccessSignature.new)
    end

    it 'succeeds to upload files' do
      files = []
      Tempfile.create('foo') do |f|
        files.push(f.path)
        puts files.inspect
        expect(SlideHub::Cloud::Engine::Azure.upload_files('container', files, 'test').class.name).to eq('Array')
      end
    end

    it 'succeeds to get file list' do
      expect(SlideHub::Cloud::Engine::Azure.get_file_list('container', 'prefix').class.name).to eq('Array')
    end

    it 'succeeds to save file' do
      Dir.mktmpdir do |dir|
        destination = "#{dir}/#{SecureRandom.hex}"
        expect(SlideHub::Cloud::Engine::Azure.save_file('container', 'key', destination)).to eq(true)
        expect(File.exist?(destination)).to eq(true)
        expect(SlideHub::Cloud::Engine::Azure.save_file('container', 'key', nil)).to eq(false)
      end
    end

    it 'succeeds to delete files and sildes' do
      expect(SlideHub::Cloud::Engine::Azure.delete_slide('')).to eq(false)
      expect(SlideHub::Cloud::Engine::Azure.delete_slide('hoge')).to eq(true)
      expect(SlideHub::Cloud::Engine::Azure.delete_generated_files('')).to eq(false)
      expect(SlideHub::Cloud::Engine::Azure.delete_generated_files('hoge')).to eq(true)
    end

    it 'succeeds to generate SAS url' do
      expect(SlideHub::Cloud::Engine::Azure.generate_sas_url('myblob')).to eq('https://signed.example.com')
    end

    it 'succeeds to get slide download url' do
      expect(SlideHub::Cloud::Engine::Azure.get_slide_download_url('myblob')).to eq('https://signed.example.com')
    end
  end
end
