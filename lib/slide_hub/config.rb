module SlideHub
  # :reek:Attribute { enabled: false }
  class Config
    # AWS
    attr_accessor :aws_access_id, :aws_secret_key, :region, :sqs_url, :use_s3_static_hosting,
                  :bucket_name, :image_bucket_name, :cdn_base_url
    # Azure
    attr_accessor :use_azure, :azure_cdn_base_url, :azure_container_name, :azure_image_container_name,
                  :azure_queue_name, :azure_storage_access_key, :azure_storage_account_name
    # 外部サービスでのログイン（Facebook / Twitter / SAML）
    attr_accessor :facebook_app_id, :facebook_app_secret,
                  :twitter_consumer_key, :twitter_consumer_secret, :twitter_callback_url,
                  :idp_cert_fingerprint, :idp_sso_target_url
    # メール
    attr_accessor :from_email, :smtp_server, :smtp_port, :smtp_auth_method, :smtp_username, :smtp_password
    # サイト
    attr_accessor :root_url, :login_required

    def azure?
      use_azure.present? && use_azure.to_i == 1
    end

    def facebook?
      facebook_app_id.present? && facebook_app_secret.present?
    end

    def twitter?
      twitter_consumer_key.present? && twitter_consumer_secret.present? && twitter_callback_url.present?
    end

    def saml?
      idp_cert_fingerprint.present? && idp_sso_target_url.present?
    end

    def mail_sender
      from_email || smtp_username || 'info@example.com'
    end
  end
end
