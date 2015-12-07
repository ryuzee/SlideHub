require 'net/http'
require 'uri'
require 'json'
require 'securerandom'

module Common
  extend ActiveSupport::Concern

  def thumbnail_url(key)
    unless (ENV['OSS_CDN_BASE_URL'].empty?)
      url = "#{ENV['OSS_CDN_BASE_URL']}/#{key}/thumbnail.jpg"
    else
      url = self.endpoint_s3(ENV['OSS_IMAGE_BUCKET_NAME']) + "/#{key}/thumbnail.jpg"
    end
    url
  end

  def endpoint_s3(bucket_name)
    if (ENV['OSS_USE_S3_STATIC_HOSTING'] == '1')
      url = "http://#{bucket_name}"
    else
      if (ENV['OSS_REGION'] == 'us-east-1')
        url = "https://#{bucket_name}.s3.amazonaws.com"
      else
        url = "https://#{bucket_name}.s3-#{ENV['OSS_REGION']}.amazonaws.com"
      end
    end
    url
  end

  def upload_endpoint
    bucket_name = ENV['OSS_BUCKET_NAME']
    if (ENV['OSS_REGION'] == 'us-east-1')
      url = "https://#{bucket_name}.s3.amazonaws.com"
    else
      url = "https://#{bucket_name}.s3-#{ENV['OSS_REGION']}.amazonaws.com"
    end
    url
  end

  def transcript_url(key)
    self.get_url("/#{key}/transcript.txt")
  end

  def page_list_url(key)
    self.get_url("/#{key}/list.json")
  end

  def get_url(path)
    unless ENV['OSS_CDN_BASE_URL'].empty?
      url = "#{ENV['OSS_CDN_BASE_URL']}#{path}"
    else
      url = self.endpoint_s3(ENV['OSS_IMAGE_BUCKET_NAME']) + "#{path}"
    end
    url
  end

  def get_pages_list(key)
    response = self.get_json(self.get_url("/#{key}/list.json"))
    response
  end

  def get_transcript(key)
    begin
      response =  Net::HTTP.get_response(URI.parse(self.get_url("/#{key}/transcript.txt")))
      case response
      when Net::HTTPSuccess
        response = response.body.dup.force_encoding('utf-8')
        require 'php_serialization/unserializer'
        return PhpSerialization::Unserializer.new.run(response)
      else
        puts response.value
        return []
        # handle error
      end
    rescue => e
      puts [e.class, e].join(' : ')
      # handle error
    end
  end

  def get_json(location, limit = 10)
    raise ArgumentError, 'too many HTTP redirects' if limit == 0
    uri = URI.parse(location)
    begin
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.open_timeout = 5
        http.read_timeout = 10
        http.get(uri.request_uri)
      end
      case response
      when Net::HTTPSuccess
        json = response.body
        JSON.parse(json)
      when Net::HTTPRedirection
        location = response['location']
        warn "redirected to #{location}"
        get_json(location, limit - 1)
      else
        puts [uri.to_s, response.value].join(' : ')
        false
      end
    rescue => e
      puts [uri.to_s, e.class, e].join(' : ')
      false
    end
  end

  def create_policy
    base_time = Time.zone.now.in_time_zone('UTC')

    if (!ENV['OSS_AWS_ACCESS_ID'].empty? && !ENV['OSS_AWS_SECRET_KEY'].empty?)
      access_id = ENV['OSS_AWS_ACCESS_ID']
      secret_key = ENV['OSS_AWS_SECRET_KEY']
      security_token = ''
    else
      ec2 = Aws::EC2::Client.new
      credential = ec2.config[:credentials]
      access_id = credential.access_key_id
      secret_key = credential.secret_access_key
      security_token = credential.session_token
    end
    region = ENV['OSS_REGION']
    bucket_name = ENV['OSS_BUCKET_NAME']

    self.populate_policy(base_time, access_id, secret_key, security_token, region, bucket_name)
  end

  def populate_policy(base_time, access_id, secret_key, security_token, region, bucket_name)
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
  def get_signing_key(shortdate, region, service, secretkey)
    datekey = OpenSSL::HMAC.digest('sha256', "AWS4#{secretkey}", shortdate)
    regionkey = OpenSSL::HMAC.digest('sha256', datekey, region)
    servicekey = OpenSSL::HMAC.digest('sha256', regionkey, service)
    signinkey = OpenSSL::HMAC.digest('sha256', servicekey, 'aws4_request')

    signinkey
  end

  def convert_slide(key)
    require 'tmpdir'
    Dir.mktmpdir do |dir|
      Oss::BatchLogger.info("Current directory is #{dir}")
      file = "#{SecureRandom.hex}"
      # @TODO:needs to be method and retry
      storage = Storage.new
      storage.save_file(ENV['OSS_BUCKET_NAME'], key, "#{dir}/#{file}")
      ft = Oss::ConvertUtil.new.get_slide_file_type("#{dir}/#{file}")
      Oss::BatchLogger.info("File Type is #{ft}")
      case ft
      when 'pdf'
        Oss::BatchLogger.info('Rename to PDF')
        Oss::ConvertUtil.new.rename_to_pdf(dir, file)
        Oss::BatchLogger.info('Start converting from PDF to PPM')
        Oss::ConvertUtil.new.pdf_to_ppm(dir, "#{file}.pdf")
      when 'ppt', 'pptx'
        Oss::BatchLogger.info('Start converting from PPT to PDF')
        Oss::ConvertUtil.new.ppt_to_pdf(dir, file)
        Oss::BatchLogger.info(Oss::ConvertUtil.new.get_local_file_list(dir, '').inspect)
        Oss::BatchLogger.info('Start converting from PDF to PPM')
        Oss::ConvertUtil.new.pdf_to_ppm(dir, "#{file}.pdf")
        Oss::BatchLogger.info(Oss::ConvertUtil.new.get_local_file_list(dir, '').inspect)
      else
        false
      end
      Oss::BatchLogger.info('Start converting from PPM to JPG')
      slide_image_list = Oss::ConvertUtil.new.ppm_to_jpg(dir)
      Oss::BatchLogger.info(Oss::ConvertUtil.new.get_local_file_list(dir, '').inspect)
      final_list = slide_image_list.dup

      self.generate_json_list(slide_image_list, key, "#{dir}/list.json")
      final_list.push("#{dir}/list.json")

      Oss::BatchLogger.info('Generating thumbnails')
      Oss::BatchLogger.info(slide_image_list.inspect)
      thumbnail_list = Oss::ConvertUtil.new.jpg_to_thumbnail(slide_image_list)
      thumbnail_list.each do |tm|
        final_list.push(tm)
      end if thumbnail_list.instance_of?(Array)

      transcript = Oss::ConvertUtil.new.pdf_to_transcript(dir, "#{file}.pdf")
      final_list.push(transcript) if transcript

      Oss::BatchLogger.info(final_list.inspect)
      storage = Storage.new
      storage.upload_files(ENV['OSS_IMAGE_BUCKET_NAME'], final_list, key)

      slide = Slide.where('slides.key = ?', key).first
      slide.convert_status = 100
      slide.save
      true
    end
  end

  def generate_json_list(list, prefix, filename)
    save_list = []
    list.each do |item|
      save_list.push("#{prefix}/#{File.basename(item)}")
    end
    open(filename, 'w') do |io|
      JSON.dump(save_list, io)
    end
  end
end
