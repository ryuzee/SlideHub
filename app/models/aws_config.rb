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
        url = "http://#{@config.image_bucket_name}"
      else
        if @config.region == 'us-east-1'
          url = "https://#{@config.image_bucket_name}.s3.amazonaws.com"
        else
          url = "https://#{@config.image_bucket_name}.s3-#{@config.region}.amazonaws.com"
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

  def self.create_policy
    base_time = Time.zone.now.in_time_zone('UTC')

    if !@config.aws_access_id.blank? && !@config.aws_secret_key.blank?
      access_id = @config.aws_access_id
      secret_key = @config.aws_secret_key
      security_token = ''
    else
      ec2 = Aws::EC2::Client.new
      credential = ec2.config[:credentials]
      access_id = credential.access_key_id
      secret_key = credential.secret_access_key
      security_token = credential.session_token
    end
    region = @config.region
    bucket_name = @config.bucket_name

    self.populate_policy(base_time, access_id, secret_key, security_token, region, bucket_name)
  end

  def self.populate_policy(base_time, access_id, secret_key, security_token, region, bucket_name)
    date_ymd = base_time.gmtime.strftime('%Y%m%d')
    date_gm = base_time.gmtime.strftime('%Y%m%dT%H%M%SZ')
    acl = 'public-read'
    exp = base_time + 60 * 120
    expires = exp.gmtime.strftime('%Y-%m-%dT%H:%M:%SZ')

    #---------------------------------------------
    # 1. Create a policy using UTF-8 encoding.
    # This includes custom meta data named "x-amz-meta-title" for example
    #---------------------------------------------
    p_array = {
      'expiration' => expires,
      'conditions' => [
        { 'bucket' => bucket_name },
        ['starts-with', '$key', ''],
        { 'acl' => acl },
        { 'success_action_status' => '201' },
        ['starts-with', '$Content-Type', 'application/octetstream'],
        { 'x-amz-meta-uuid' => '14365123651274' },
        ['starts-with', '$x-amz-meta-tag', ''],
        { 'x-amz-credential' => "#{access_id}/#{date_ymd}/#{region}/s3/aws4_request" },
        { 'x-amz-algorithm' => 'AWS4-HMAC-SHA256' },
        { 'x-amz-date' => date_gm },
      ],
    }

    unless security_token.empty?
      p_array['conditions'].push({ 'x-amz-security-token' => security_token })
    end

    policy = JSON.generate(p_array)

    #---------------------------------------------
    # 2. Convert the UTF-8-encoded policy to Base64. The result is the string to sign.
    #---------------------------------------------
    base64_policy = Base64.strict_encode64(policy)

    #---------------------------------------------
    # 3. Create the signature as an HMAC-SHA256 hash of the string to sign. You will provide the signing key as key to the hash function.
    #---------------------------------------------
    # https://github.com/aws/aws-sdk-php/blob/00c4d18d666d2da44814daca48deb33e20cc4d3c/src/Aws/Common/Signature/SignatureV4.php
    signinkey = self.get_signing_key(date_ymd, region, 's3', secret_key)
    signature = OpenSSL::HMAC.hexdigest('sha256', signinkey, base64_policy)

    result = {
      'access_id' => access_id,
      'base64_policy' => base64_policy,
      'date_ymd' => date_ymd,
      'date_gm' => date_gm,
      'acl' => acl,
      'security_token' => security_token,
      'signature' => signature,
      'success_action_status' => '201',
    }
    result
  end

  # get several key for AWS API.
  # @param string $shortdate
  # @param string $region
  # @param string $service
  # @param string $secretkey
  # @return tring
  def self.get_signing_key(shortdate, region, service, secretkey)
    datekey = OpenSSL::HMAC.digest('sha256', "AWS4#{secretkey}", shortdate)
    regionkey = OpenSSL::HMAC.digest('sha256', datekey, region)
    servicekey = OpenSSL::HMAC.digest('sha256', regionkey, service)
    signinkey = OpenSSL::HMAC.digest('sha256', servicekey, 'aws4_request')

    signinkey
  end
end
