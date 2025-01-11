def slidehub_config
  Rails.application.config.slidehub
end

module CloudConfig
  class << self
    # provider を保存するインスタンス変数
    attr_accessor :provider

    # 初期値の設定
    def setup_defaults(config)
      @provider = config.azure? ? SlideHub::Cloud::Engine::Azure : SlideHub::Cloud::Engine::Aws
    end

    # サービス名を取得する
    def service_name
      @provider == SlideHub::Cloud::Engine::Azure ? 'azure' : 'aws'
    end
  end
end

if slidehub_config.azure?
  SlideHub::Cloud::Engine::Azure.configure do |config|
    config.bucket_name = slidehub_config.azure_container_name
    config.image_bucket_name = slidehub_config.azure_image_container_name
    config.cdn_base_url = slidehub_config.azure_cdn_base_url
    config.queue_name = slidehub_config.azure_queue_name
    config.azure_storage_access_key = slidehub_config.azure_storage_access_key
    config.azure_storage_account_name = slidehub_config.azure_storage_account_name
  end
  Rails.application.config.active_storage.service = :azure
else
  SlideHub::Cloud::Engine::Aws.configure do |config|
    config.region = slidehub_config.region
    config.aws_access_id = slidehub_config.aws_access_id
    config.aws_secret_key = slidehub_config.aws_secret_key
    config.bucket_name = slidehub_config.bucket_name
    config.image_bucket_name = slidehub_config.image_bucket_name
    config.sqs_url = slidehub_config.sqs_url
    config.use_s3_static_hosting = slidehub_config.use_s3_static_hosting
    config.cdn_base_url = slidehub_config.cdn_base_url
  end
  Rails.application.config.active_storage.service = :amazon
end

CloudConfig.setup_defaults(Rails.application.config.slidehub)


