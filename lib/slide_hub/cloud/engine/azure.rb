require 'json'
require 'azure/storage/blob'
require 'azure/storage/queue'
require 'azure/storage/common/core/auth/shared_access_signature'

module SlideHub
  module Cloud
    module Engine
      class Azure
        class Config
          include ActiveSupport::Configurable
          config_accessor :bucket_name
          config_accessor :image_bucket_name
          config_accessor :cdn_base_url
          config_accessor :queue_name
          config_accessor :azure_storage_access_key
          config_accessor :azure_storage_account_name
        end

        def self.configure(&block)
          yield config
          #::Azure.config.storage_account_name = @config.azure_storage_account_name
          #::Azure.config.storage_access_key = @config.azure_storage_access_key
        end

        def self.config
          @config ||= Config.new
        end

        def self.queue_endpoint
          url = "https://#{@config.azure_storage_account_name}.queue.core.windows.net/"
          url
        end

        def self.resource_endpoint
          return "#{@config.cdn_base_url}/#{@config.image_bucket_name}" if @config.cdn_base_url.present?

          "https://#{@config.azure_storage_account_name}.blob.core.windows.net/#{@config.image_bucket_name}"
        end

        def self.upload_endpoint
          url = "https://#{@config.azure_storage_account_name}.blob.core.windows.net/#{@config.bucket_name}"
          url
        end

        def self.create_qs
          qs = ::Azure::Storage::Queue::QueueService.create(
            storage_account_name: @config.azure_storage_account_name,
            storage_access_key: @config.azure_storage_access_key,
          )
          qs
        end

        # FIXME
        def self.send_message(message)
          qs = create_qs
          resp = qs.create_message(@config.queue_name, message)
          resp
        end

        def self.receive_message(max_number = 10)
          qs = create_qs
          response = qs.list_messages(@config.queue_name, 600, { number_of_messages: max_number })
          # see http://www.rubydoc.info/github/Azure/azure-sdk-for-ruby/Azure%2FQueue%2FQueueService%3Alist_messages
          # it returns a list of Azure::Entity::Queue::Message instances
          # http://www.rubydoc.info/github/Azure/azure-sdk-for-ruby/Azure/Queue/Message
          result = SlideHub::Cloud::Queue::Response.new
          unless !response || response.count.zero?
            response.each do |msg|
              result.add_message(msg.id, msg.message_text, msg.pop_receipt)
            end
          end
          result
        end

        # FIXME
        def self.delete_message(message_object)
          qs = create_qs
          qs.create_queue(@config.queue_name)
          resp = qs.delete_message(@config.queue_name, message_object.id, message_object.handle)
          resp
        end

        def self.batch_delete(entries)
          result = true
          entries.each do |entry|
            result = self.delete_message(entry)
          end
          result
        end

        ## Blob
        def self.create_bs
          bs = ::Azure::Storage::Blob::BlobService.create(
            storage_account_name: @config.azure_storage_account_name,
            storage_access_key: @config.azure_storage_access_key,
          )
          bs
        end

        def self.upload_files(container, files, prefix)
          bs = create_bs
          files.each do |file|
            next unless File.exist?(file)

            content = File.open(file, 'rb', &:read)
            require 'mime/types'
            content_type = MIME::Types.type_for(File.extname(file))[0].to_s
            bs.create_block_blob(container, "#{prefix}/#{File.basename(file)}", content, { content_type: content_type })
          end
        end

        def self.get_file_list(container, prefix)
          bs = create_bs
          resp = bs.list_blobs(container, { prefix: prefix, max_results: 1000 })
          files = []
          resp.each do |blob|
            files.push({ key: blob.name })
          end
          files
        end

        def self.save_file(container, key, destination)
          bs = create_bs
          _blob, content = bs.get_blob(container, key)
          File.open(destination, 'wb') { |file| file.write(content) }
          true
        rescue StandardError
          false
        end

        def self.delete_slide(key)
          if key.empty?
            return false
          end

          files = self.get_file_list(@config.bucket_name, key)
          self.delete_files(@config.bucket_name, files)
          true
        end

        def self.delete_generated_files(key)
          if key.empty?
            return false
          end

          files = self.get_file_list(@config.image_bucket_name, key)
          self.delete_files(@config.image_bucket_name, files)
          true
        end

        def self.get_slide_download_url(key)
          self.get_download_url(@config.bucket_name, key)
        end

        def self.delete_files(container, files)
          bs = create_bs
          files.each do |file|
            bs.delete_blob(container, file[:key])
          end
        end

        # `container` is only for duck typing
        # :reek:UnusedParameters
        def self.get_download_url(container, key)
          url = self.generate_sas_url(key)
          url
        end

        def self.generate_sas_url(blob_name)
          permissions = 'rw'

          start_time = Time.zone.now - 10
          expiration_time = Time.zone.now + 1800
          bs = create_bs
          uri = bs.generate_uri Addressable::URI.escape("#{@config.bucket_name}/#{blob_name}"), {}
          uri.scheme = 'https'

          signer = ::Azure::Storage::Common::Core::Auth::SharedAccessSignature.new(
            @config.azure_storage_account_name,
            @config.azure_storage_access_key,
          )

          url = signer.signed_uri(
            uri,
            false,
            service: 'b',
            permissions: permissions,
            start: start_time.utc.iso8601,
            expiry: expiration_time.utc.iso8601,
          ).to_s
          url
        end
      end
    end
  end
end
