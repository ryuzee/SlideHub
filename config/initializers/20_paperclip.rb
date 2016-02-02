if AWSConfig.config.aws_access_id.blank? && AWSConfig.config.aws_secret_key.blank?
  cred = {
    bucket: AWSConfig.config.image_bucket_name
  }
else
  cred = {
    bucket: AWSConfig.config.image_bucket_name,
    access_key_id: AWSConfig.config.aws_access_id,
    secret_access_key: AWSConfig.config.aws_secret_key,
  }
end
Paperclip::Attachment.default_options[:storage] = :s3
Paperclip::Attachment.default_options[:s3_host_name] = AWSConfig.s3_host_name
Paperclip::Attachment.default_options[:s3_region] = AWSConfig.config.region
Paperclip::Attachment.default_options[:s3_credentials] = cred
