class Storage
  include ActiveSupport::Configurable

  config_accessor :bucket_name
  config_accessor :image_bucket_name
  config_accessor :use_s3_static_hosting
  config_accessor :region
  config_accessor :cdn_base_url
  config_accessor :sqs_url
  config_accessor :aws_access_id
  config_accessor :aws_secret_key

  def initialize
    if defined? self.aws_access_id && defined? self.aws_secret_key && !self.aws_access_id.empty? && !self.aws_secret_key.empty?
      Aws.config.update({
        region: self.region,
        credentials: Aws::Credentials.new(self.aws_access_id, self.aws_secret_key),
      },)
    end
    @client = Aws::S3::Client.new(region: region)
  end

  def upload_files(bucket, files, prefix)
    files.each do |f|
      @client.put_object(
        bucket: bucket,
        key: "#{prefix}/#{File.basename(f)}",
        body: File.read(f),
          acl: 'public-read',
          storage_class: 'REDUCED_REDUNDANCY',
      ) if File.exist?(f)
    end
  end

  def get_file_list(bucket, prefix)
    resp = @client.list_objects({
      bucket: bucket,
      max_keys: 1000,
      prefix: prefix,
    },)
    files = []
    resp.contents.each do |f|
      files.push({ key: f.key })
    end
    files
  end

  def save_file(bucket, key, destination)
    @client.get_object(
        response_target: destination,
        bucket: bucket,
        key: key)
  end

  def delete_slide(key)
    if key.empty?
      return false
    end
    files = self.get_file_list(self.bucket_name, key)
    self.delete_files(self.bucket_name, files)
    true
  end

  def delete_generated_files(key)
    if key.empty?
      return false
    end
    files = self.get_file_list(self.image_bucket_name, key)
    self.delete_files(self.image_bucket_name, files)
    true
  end

  def get_slide_download_url(key)
    self.get_download_url(self.bucket_name, key)
  end

  def delete_files(bucket, files)
    @client.delete_objects({
      bucket: bucket,
      delete: {
        objects: files,
        quiet: true,
      },
    },) unless files.empty?
  end

  def get_download_url(bucket, key)
    signer = Aws::S3::Presigner.new(client: @client)
    url = signer.presigned_url(:get_object, bucket: bucket, key: key)
    url
  end
end
