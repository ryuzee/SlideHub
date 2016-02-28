if CloudConfig.service_name == 'aws'
  if AWSConfig.config.aws_access_id.blank? && AWSConfig.config.aws_secret_key.blank?
    cred = {
      bucket: AWSConfig.config.image_bucket_name,
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
end

if CloudConfig.service_name == 'azure'
  Paperclip::Attachment.default_options[:storage] = :azure
  Paperclip::Attachment.default_options[:url] = ':azure_path_url'
  Paperclip::Attachment.default_options[:path] = ':class/:attachment/:id/:style/:filename'
  Paperclip::Attachment.default_options[:azure_credentials] = {
    storage_account_name: AzureConfig.config.azure_storage_account_name,
    access_key:           AzureConfig.config.azure_storage_access_key,
    container:            AzureConfig.config.image_bucket_name,
  }
end
