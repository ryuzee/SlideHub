module SlideHub
  class Railtie < Rails::Railtie
    config.slidehub = SlideHub::Config.new
    # AWS
    config.slidehub.aws_access_id = ENV.fetch('OSS_AWS_ACCESS_ID', nil)
    config.slidehub.aws_secret_key = ENV.fetch('OSS_AWS_SECRET_KEY', nil)
    config.slidehub.region = ENV.fetch('OSS_REGION', nil)
    config.slidehub.bucket_name = ENV.fetch('OSS_BUCKET_NAME', nil)
    config.slidehub.image_bucket_name = ENV.fetch('OSS_IMAGE_BUCKET_NAME', nil)
    config.slidehub.cdn_base_url = ENV.fetch('OSS_CDN_BASE_URL', nil)
    config.slidehub.sqs_url = ENV.fetch('OSS_SQS_URL', nil)
    config.slidehub.use_s3_static_hosting = ENV.fetch('OSS_USE_S3_STATIC_HOSTING', nil)
    # Azure
    config.slidehub.use_azure = ENV.fetch('OSS_USE_AZURE', nil)
    config.slidehub.azure_cdn_base_url = ENV.fetch('OSS_AZURE_CDN_BASE_URL', nil)
    config.slidehub.azure_container_name = ENV.fetch('OSS_AZURE_CONTAINER_NAME', nil)
    config.slidehub.azure_image_container_name = ENV.fetch('OSS_AZURE_IMAGE_CONTAINER_NAME', nil)
    config.slidehub.azure_queue_name = ENV.fetch('OSS_AZURE_QUEUE_NAME', nil)
    config.slidehub.azure_storage_access_key = ENV.fetch('OSS_AZURE_STORAGE_ACCESS_KEY', nil)
    config.slidehub.azure_storage_account_name = ENV.fetch('OSS_AZURE_STORAGE_ACCOUNT_NAME', nil)
    # App
    config.slidehub.facebook_app_id = ENV.fetch('OSS_FACEBOOK_APP_ID', nil)
    config.slidehub.facebook_app_secret = ENV.fetch('OSS_FACEBOOK_APP_SECRET', nil)
    config.slidehub.twitter_consumer_key = ENV.fetch('OSS_TWITTER_CONSUMER_KEY', nil)
    config.slidehub.twitter_consumer_secret = ENV.fetch('OSS_TWITTER_CONSUMER_SECRET', nil)
    config.slidehub.twitter_callback_url = ENV.fetch('OSS_TWITTER_CALLBACK_URL', nil)
    config.slidehub.idp_cert_fingerprint = ENV.fetch('OSS_IDP_CERT_FINGERPRINT', nil)
    config.slidehub.idp_sso_target_url = ENV.fetch('OSS_IDP_SSO_TERGET_URL', nil)

    # mail
    config.slidehub.from_email = ENV.fetch('OSS_FROM_EMAIL', nil)
    config.slidehub.smtp_server = ENV.fetch('OSS_SMTP_SERVER', nil)
    config.slidehub.smtp_port = ENV.fetch('OSS_SMTP_PORT', nil)
    config.slidehub.smtp_auth_method = ENV.fetch('OSS_SMTP_AUTH_METHOD', nil)
    config.slidehub.smtp_password = ENV.fetch('OSS_SMTP_PASSWORD', nil)
    config.slidehub.smtp_username = ENV.fetch('OSS_SMTP_USERNAME', nil)

    # others
    config.slidehub.root_url = ENV.fetch('OSS_ROOT_URL', nil)
    config.slidehub.login_required = ENV.fetch('OSS_LOGIN_REQUIRED', nil)
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
