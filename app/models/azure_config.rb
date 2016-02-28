require 'azure'
require 'azure-contrib'
require 'json'

class AzureConfig
  class Config
    include ActiveSupport::Configurable
    config_accessor :container_name
    config_accessor :image_container_name
    config_accessor :cdn_base_url
    config_accessor :queue_name
    config_accessor :azure_storage_access_key
    config_accessor :azure_storage_account_name
  end

  def self.configure(&block)
    yield config
    Azure.config.storage_account_name = config.azure_storage_account_name
    Azure.config.storage_access_key = config.azure_storage_access_key
    puts "=========================="
    puts config.azure_storage_account_name
    puts "=========================="
  end

  def self.config
    @config ||= Config.new
  end

  def self.queue_endpoint
    url = "https://#{@config.azure_storage_account_name}.queue.core.windows.net/"
    url
  end

  def self.resource_endpoint
    unless @config.cdn_base_url.blank?
      url = @config.cdn_base_url
    else
      url = "https://#{@config.azure_storage_account_name}.blob.core.windows.net/#{@config.image_container_name}"
    end
    url
  end

  def self.upload_endpoint
    url = "https://#{@config.azure_storage_account_name}.blob.core.windows.net/#{@config.container_name}"
    url
  end

  def self.send_message(message)
    queues = Azure.queues
    resp = queues.create_message(@config.queue_name, message)
    resp
  end

  def self.receive_message(max_number = 10)
    queues = Azure.queues
    result = queues.list_messages(@config.queue_name, 600, {:number_of_messages => max_number})
    result
  end

  def self.delete_message(message_object)
    queues = Azure.queues
    resp = queues.delete_message(@config.queue_name, message_object.id, message_object.pop_receipt)
    resp
  end

  def self.batch_delete(entries)
    entries.each do |entry|
      self.delete_message(entry)
    end
  end

  def self.generate_sas_url(blob_name)
    permissions = 'w'

    start_time = Time.now - 10
    expiration_time = Time.now + 1800
    bs = Azure::Blob::BlobService.new
    uri = bs.generate_uri Addressable::URI.escape("#{@config.container_name}/#{blob_name}"), {}

    signer = Azure::Contrib::Auth::SharedAccessSignature.new(uri, {
      resource:    "b",
      permissions: permissions,
      start:       start_time.utc.iso8601,
      expiry:      expiration_time.utc.iso8601
    }, Azure.config.storage_account_name)

    url = signer.sign
    url
  end
end
