require_relative '../../lib/slide_hub/config'
require_relative '../../lib/slide_hub/env_util'

Rails.application.config.slidehub = SlideHub::Config.new

# AWS
Rails.application.config.slidehub.aws_access_id = SlideHub::EnvUtil.fetch('AWS_ACCESS_ID')
Rails.application.config.slidehub.aws_secret_key = SlideHub::EnvUtil.fetch('AWS_SECRET_KEY')
Rails.application.config.slidehub.region = SlideHub::EnvUtil.fetch('REGION')
Rails.application.config.slidehub.bucket_name = SlideHub::EnvUtil.fetch('BUCKET_NAME')
Rails.application.config.slidehub.image_bucket_name = SlideHub::EnvUtil.fetch('IMAGE_BUCKET_NAME')
Rails.application.config.slidehub.cdn_base_url = SlideHub::EnvUtil.fetch('CDN_BASE_URL')
Rails.application.config.slidehub.sqs_url = SlideHub::EnvUtil.fetch('SQS_URL')
Rails.application.config.slidehub.use_s3_static_hosting = SlideHub::EnvUtil.fetch('USE_S3_STATIC_HOSTING')

# Azure
Rails.application.config.slidehub.use_azure = SlideHub::EnvUtil.fetch('USE_AZURE')
Rails.application.config.slidehub.azure_cdn_base_url = SlideHub::EnvUtil.fetch('AZURE_CDN_BASE_URL')
Rails.application.config.slidehub.azure_container_name = SlideHub::EnvUtil.fetch('AZURE_CONTAINER_NAME')
Rails.application.config.slidehub.azure_image_container_name = SlideHub::EnvUtil.fetch('AZURE_IMAGE_CONTAINER_NAME')
Rails.application.config.slidehub.azure_queue_name = SlideHub::EnvUtil.fetch('AZURE_QUEUE_NAME')
Rails.application.config.slidehub.azure_storage_access_key = SlideHub::EnvUtil.fetch('AZURE_STORAGE_ACCESS_KEY')
Rails.application.config.slidehub.azure_storage_account_name = SlideHub::EnvUtil.fetch('AZURE_STORAGE_ACCOUNT_NAME')

# App
Rails.application.config.slidehub.facebook_app_id = SlideHub::EnvUtil.fetch('FACEBOOK_APP_ID')
Rails.application.config.slidehub.facebook_app_secret = SlideHub::EnvUtil.fetch('FACEBOOK_APP_SECRET')
Rails.application.config.slidehub.twitter_consumer_key = SlideHub::EnvUtil.fetch('TWITTER_CONSUMER_KEY')
Rails.application.config.slidehub.twitter_consumer_secret = SlideHub::EnvUtil.fetch('TWITTER_CONSUMER_SECRET')
Rails.application.config.slidehub.twitter_callback_url = SlideHub::EnvUtil.fetch('TWITTER_CALLBACK_URL')
Rails.application.config.slidehub.idp_cert_fingerprint = SlideHub::EnvUtil.fetch('IDP_CERT_FINGERPRINT')
Rails.application.config.slidehub.idp_sso_target_url = SlideHub::EnvUtil.fetch('IDP_SSO_TARGET_URL')

# Mail
Rails.application.config.slidehub.from_email = SlideHub::EnvUtil.fetch('FROM_EMAIL')
Rails.application.config.slidehub.smtp_server = SlideHub::EnvUtil.fetch('SMTP_SERVER')
Rails.application.config.slidehub.smtp_port = SlideHub::EnvUtil.fetch('SMTP_PORT')
Rails.application.config.slidehub.smtp_auth_method = SlideHub::EnvUtil.fetch('SMTP_AUTH_METHOD')
Rails.application.config.slidehub.smtp_password = SlideHub::EnvUtil.fetch('SMTP_PASSWORD')
Rails.application.config.slidehub.smtp_username = SlideHub::EnvUtil.fetch('SMTP_USERNAME')

# Others
Rails.application.config.slidehub.root_url = SlideHub::EnvUtil.fetch('ROOT_URL')
Rails.application.config.slidehub.login_required = SlideHub::EnvUtil.fetch('LOGIN_REQUIRED')

Rails.application.config.action_mailer.delivery_method = :smtp
Rails.application.config.action_mailer.smtp_settings = {
  address: Rails.application.config.slidehub.smtp_server,
  port: Rails.application.config.slidehub.smtp_port,
  authentication: Rails.application.config.slidehub.smtp_auth_method,
  user_name: Rails.application.config.slidehub.smtp_username,
  password: Rails.application.config.slidehub.smtp_password,
}
