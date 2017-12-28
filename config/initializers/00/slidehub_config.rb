module SlideHub
  class Railtie < Rails::Railtie
    config.slidehub = SlideHub::Config.new
    # AWS
    config.slidehub.aws_access_id = ENV['OSS_AWS_ACCESS_ID']
    config.slidehub.aws_secret_key = ENV['OSS_AWS_SECRET_KEY']
    config.slidehub.region = ENV['OSS_REGION']
    config.slidehub.bucket_name = ENV['OSS_BUCKET_NAME']
    config.slidehub.image_bucket_name = ENV['OSS_IMAGE_BUCKET_NAME']
    config.slidehub.cdn_base_url = ENV['OSS_CDN_BASE_URL']
    config.slidehub.sqs_url = ENV['OSS_SQS_URL']
    config.slidehub.use_s3_static_hosting = ENV['OSS_USE_S3_STATIC_HOSTING']
    # Azure
    config.slidehub.use_azure = ENV['OSS_USE_AZURE']
    config.slidehub.azure_cdn_base_url = ENV['OSS_AZURE_CDN_BASE_URL']
    config.slidehub.azure_container_name = ENV['OSS_AZURE_CONTAINER_NAME']
    config.slidehub.azure_image_container_name = ENV['OSS_AZURE_IMAGE_CONTAINER_NAME']
    config.slidehub.azure_queue_name = ENV['OSS_AZURE_QUEUE_NAME']
    config.slidehub.azure_storage_access_key = ENV['OSS_AZURE_STORAGE_ACCESS_KEY']
    config.slidehub.azure_storage_account_name = ENV['OSS_AZURE_STORAGE_ACCOUNT_NAME']
    # App
    config.slidehub.facebook_app_id = ENV['OSS_FACEBOOK_APP_ID']
    config.slidehub.facebook_app_secret = ENV['OSS_FACEBOOK_APP_SECRET']
    config.slidehub.twitter_consumer_key = ENV['OSS_TWITTER_CONSUMER_KEY']
    config.slidehub.twitter_consumer_secret = ENV['OSS_TWITTER_CONSUMER_SECRET']

    # mail
    config.slidehub.from_email = ENV['OSS_FROM_EMAIL']
    config.slidehub.smtp_server = ENV['OSS_SMTP_SERVER']
    config.slidehub.smtp_port = ENV['OSS_SMTP_PORT']
    config.slidehub.smtp_auth_method = ENV['OSS_SMTP_AUTH_METHOD']
    config.slidehub.smtp_password = ENV['OSS_SMTP_PASSWORD']
    config.slidehub.smtp_username = ENV['OSS_SMTP_USERNAME']

    # others
    config.slidehub.root_url = ENV['OSS_ROOT_URL']
  end
end

Rails.application.config.action_mailer.delivery_method = :smtp
Rails.application.config.action_mailer.smtp_settings = {
  address: Rails.application.config.slidehub.smtp_server,
  port: Rails.application.config.slidehub.smtp_port,
  authentication: Rails.application.config.slidehub.smtp_auth_method,
  user_name: Rails.application.config.slidehub.smtp_username,
  password: Rails.application.config.slidehub.smtp_password,
}

if Rails.env.production?
  Rails.application.config.action_mailer.default_url_options = { host: Rails.application.config.slidehub.root_url }
end
