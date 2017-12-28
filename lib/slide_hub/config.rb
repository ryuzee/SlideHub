module SlideHub
  # :reek:Attribute { enabled: false }
  class Config
    attr_accessor :aws_access_id, :aws_secret_key, :region, :sqs_url, :use_s3_static_hosting
    attr_accessor :bucket_name, :image_bucket_name, :cdn_base_url

    attr_accessor :use_azure, :azure_cdn_base_url, :azure_container_name, :azure_image_container_name, :azure_queue_name
    attr_accessor :azure_storage_access_key, :azure_storage_account_name

    attr_accessor :facebook_app_id, :facebook_app_secret
    attr_accessor :twitter_consumer_key, :twitter_consumer_secret

    attr_accessor :from_email
    attr_accessor :smtp_server, :smtp_port, :smtp_auth_method, :smtp_username, :smtp_password
    attr_accessor :root_url

    def azure?
      use_azure.present? && use_azure.to_i == 1
    end

    def facebook?
      facebook_app_id.present? && facebook_app_secret.present?
    end

    def twitter?
      twitter_consumer_key.present? && twitter_consumer_secret.present?
    end

    def mail_sender
      from_email || smtp_username || 'info@example.com'
    end
  end
end
