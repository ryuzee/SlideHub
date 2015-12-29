class StorageConfig
  class Config
    include ActiveSupport::Configurable
    config_accessor :bucket_name
    config_accessor :image_bucket_name
    config_accessor :use_s3_static_hosting
    config_accessor :region
    config_accessor :cdn_base_url
    config_accessor :sqs_url
    config_accessor :aws_access_id
    config_accessor :aws_secret_key
  end

  def self.configure(&block)
    yield config
  end

  def self.config
    @config ||= Config.new
  end
end
