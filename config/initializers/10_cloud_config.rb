if ENV.has_key?('OSS_USE_AZURE') && ENV['OSS_USE_AZURE'].to_i == 1
  AzureEngine.configure do |config|
    config.bucket_name = ENV['OSS_AZURE_CONTAINER_NAME']
    config.image_bucket_name = ENV['OSS_AZURE_IMAGE_CONTAINER_NAME']
    config.cdn_base_url = ENV['OSS_AZURE_CDN_BASE_URL']
    config.queue_name = ENV['OSS_AZURE_QUEUE_NAME']
    config.azure_storage_access_key = ENV['OSS_AZURE_STORAGE_ACCESS_KEY']
    config.azure_storage_account_name = ENV['OSS_AZURE_STORAGE_ACCOUNT_NAME']
  end
else
  AWSEngine.configure do |config|
    config.region = ENV['OSS_REGION']
    config.aws_access_id = ENV['OSS_AWS_ACCESS_ID']
    config.aws_secret_key = ENV['OSS_AWS_SECRET_KEY']
    config.bucket_name = ENV['OSS_BUCKET_NAME']
    config.image_bucket_name = ENV['OSS_IMAGE_BUCKET_NAME']
    config.sqs_url = ENV['OSS_SQS_URL']
    config.use_s3_static_hosting = ENV['OSS_USE_S3_STATIC_HOSTING']
    config.cdn_base_url = ENV['OSS_CDN_BASE_URL']
  end
end

module CloudConfig
  SERVICE = if ENV.has_key?('OSS_USE_AZURE') && ENV['OSS_USE_AZURE'].to_i == 1
              AzureEngine
            else
              AWSEngine
            end

  def self.service_name
    if ENV.has_key?('OSS_USE_AZURE') && ENV['OSS_USE_AZURE'].to_i == 1
      'azure'
    else
      'aws'
    end
  end
end
