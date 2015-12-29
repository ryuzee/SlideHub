StorageConfig.configure do |config|
  config.region = ENV['OSS_REGION']
  config.aws_access_id = ENV['OSS_AWS_ACCESS_ID']
  config.aws_secret_key = ENV['OSS_AWS_SECRET_KEY']
  config.bucket_name = ENV['OSS_BUCKET_NAME']
  config.image_bucket_name = ENV['OSS_IMAGE_BUCKET_NAME']
end
