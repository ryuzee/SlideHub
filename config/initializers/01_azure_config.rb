AzureConfig.configure do |config|
  config.container_name = ENV['OSS_AZURE_CONTAINER_NAME']
  config.image_container_name = ENV['OSS_AZURE_IMAGE_CONTAINER_NAME']
  config.cdn_base_url = ENV['OSS_AZURE_CDN_BASE_URL']
  config.queue_name = ENV['OSS_AZURE_QUEUE_NAME']
  config.azure_storage_access_key = ENV['OSS_AZURE_STORAGE_ACCESS_KEY']
  config.azure_storage_account_name = ENV['OSS_AZURE_STORAGE_ACCOUNT_NAME']
end
