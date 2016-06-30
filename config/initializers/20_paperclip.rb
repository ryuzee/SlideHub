if CloudConfig.service_name == 'aws'
  if SlideHub::Cloud::AWSEngine.config.aws_access_id.blank? && AWSEngine.config.aws_secret_key.blank?
    cred = {
      bucket: SlideHub::Cloud::AWSEngine.config.image_bucket_name,
    }
  else
    cred = {
      bucket: SlideHub::Cloud::AWSEngine.config.image_bucket_name,
      access_key_id: SlideHub::Cloud::AWSEngine.config.aws_access_id,
      secret_access_key: SlideHub::Cloud::AWSEngine.config.aws_secret_key,
    }
  end
  Paperclip::Attachment.default_options[:storage] = :s3
  Paperclip::Attachment.default_options[:s3_host_name] = SlideHub::Cloud::AWSEngine.s3_host_name
  Paperclip::Attachment.default_options[:s3_region] = SlideHub::Cloud::AWSEngine.config.region
  Paperclip::Attachment.default_options[:s3_credentials] = cred
end

if CloudConfig.service_name == 'azure'
  Paperclip::Attachment.default_options[:storage] = :azure
  Paperclip::Attachment.default_options[:url] = ':azure_path_url'
  Paperclip::Attachment.default_options[:path] = ':class/:attachment/:id/:style/:filename'
  Paperclip::Attachment.default_options[:azure_credentials] = {
    storage_account_name: SlideHub::Cloud::AzureEngine.config.azure_storage_account_name,
    access_key:           SlideHub::Cloud::AzureEngine.config.azure_storage_access_key,
    container:            SlideHub::Cloud::AzureEngine.config.image_bucket_name,
  }
end
