if Rails.application.config.slidehub.azure?
  SlideHub::Cloud::Engine::Azure.configure do |config|
    config.bucket_name = Rails.application.config.slidehub.azure_container_name
    config.image_bucket_name = Rails.application.config.slidehub.azure_image_container_name
    config.cdn_base_url = Rails.application.config.slidehub.azure_cdn_base_url
    config.queue_name = Rails.application.config.slidehub.azure_queue_name
    config.azure_storage_access_key = Rails.application.config.slidehub.azure_storage_access_key
    config.azure_storage_account_name = Rails.application.config.slidehub.azure_storage_account_name
  end
  Rails.application.config.active_storage.service = :azure
else
  SlideHub::Cloud::Engine::AWS.configure do |config|
    config.region = Rails.application.config.slidehub.region
    config.aws_access_id = Rails.application.config.slidehub.aws_access_id
    config.aws_secret_key = Rails.application.config.slidehub.aws_secret_key
    config.bucket_name = Rails.application.config.slidehub.bucket_name
    config.image_bucket_name = Rails.application.config.slidehub.image_bucket_name
    config.sqs_url = Rails.application.config.slidehub.sqs_url
    config.use_s3_static_hosting = Rails.application.config.slidehub.use_s3_static_hosting
    config.cdn_base_url = Rails.application.config.slidehub.cdn_base_url
  end
  Rails.application.config.active_storage.service = :amazon
end

module CloudConfig
  SERVICE = if Rails.application.config.slidehub.azure?
              SlideHub::Cloud::Engine::Azure
            else
              SlideHub::Cloud::Engine::AWS
            end

  def self.service_name
    if Rails.application.config.slidehub.azure?
      'azure'
    else
      'aws'
    end
  end
end
