require 'azure'
require 'azure-contrib'
require 'json'

class AzureConfig
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
    Azure.config.storage_account_name = @config.azure_storage_account_name
    Azure.config.storage_access_key = @config.azure_storage_access_key
    @blob_client = Azure.blobs
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
      url = "https://#{@config.azure_storage_account_name}.blob.core.windows.net/#{@config.image_bucket_name}"
    end
    url
  end

  def self.upload_endpoint
    url = "https://#{@config.azure_storage_account_name}.blob.core.windows.net/#{@config.bucket_name}"
    url
  end

  def self.send_message(message)
    queues = Azure.queues
    resp = queues.create_message(@config.queue_name, message)
    resp
  end

  def self.receive_message(max_number = 10)
    queues = Azure.queues
    res = queues.list_messages(@config.queue_name, 600, {:number_of_messages => max_number})
    res
  end

  def self.message_exist?(resp)
    if !resp || resp.count == 0
      false
    else
      true
    end
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

  ## Blob
  def self.upload_files(container, files, prefix)
    files.each do |f|
      if File.exist?(f)
        content = File.open(f, 'rb') { |file| file.read }
        @blob_client.create_block_blob(container, "#{prefix}/#{File.basename(f)}", content)
      end
    end
  end

  def self.get_file_list(container, prefix)
    resp = @blob_client.list_blobs(container, { :prefix => prefix, :max_results => 1000 })
    files = []
    resp.each do |blob|
      files.push({ key: blob.name })
    end
    files
  end

  def self.save_file(container, key, destination)
    blob, content = @blob_client.get_blob(container, key)
    File.open(destination, "wb") {|f| f.write(content)}
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
    files.each do |f|
      @blob_client.delete_blob(container, f)
    end
  end

  def self.get_download_url(container, key)
    url = self.generate_sas_url(key)
    puts url
    url
  end

  def self.generate_sas_url(blob_name)
    permissions = 'rw'

    start_time = Time.now - 10
    expiration_time = Time.now + 1800
    bs = Azure::Blob::BlobService.new
    uri = bs.generate_uri Addressable::URI.escape("#{@config.bucket_name}/#{blob_name}"), {}

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
