class AWSConfig
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

  def self.resource_endpoint
    unless @config.cdn_base_url.blank?
      url = @config.cdn_base_url
    else
      if @config.use_s3_static_hosting == '1'
        url = "http://#{@config.bucket_name}"
      else
        if @config.region == 'us-east-1'
          url = "https://#{@config.bucket_name}.s3.amazonaws.com"
        else
          url = "https://#{@config.bucket_name}.s3-#{@config.region}.amazonaws.com"
        end
      end
    end
    url
  end

  def self.upload_endpoint
    if @config.region == 'us-east-1'
      url = "https://#{@config.bucket_name}.s3.amazonaws.com"
    else
      url = "https://#{@config.bucket_name}.s3-#{@config.region}.amazonaws.com"
    end
    url
  end

  def self.s3_host_name
    if @config.region == 'us-east-1'
      s3_host_name = 's3.amazonaws.com'
    else
      s3_host_name = "s3-#{@config.region}.amazonaws.com"
    end
    s3_host_name
  end
end
