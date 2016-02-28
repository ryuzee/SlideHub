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
end
