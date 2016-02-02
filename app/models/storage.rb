class Storage
  def initialize
    if self.configured?
      Aws.config.update({
        region: StorageConfig.config.region,
        credentials: Aws::Credentials.new(StorageConfig.config.aws_access_id, StorageConfig.config.aws_secret_key),
      },)
    end
    @client = Aws::S3::Client.new(region: StorageConfig.config.region)
  end

  def configured?
    return false unless defined? StorageConfig.config.aws_access_id
    return false unless defined? StorageConfig.config.aws_secret_key
    return false if StorageConfig.config.aws_access_id.blank?
    return false if StorageConfig.config.aws_secret_key.blank?
    true
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
    files = self.get_file_list(StorageConfig.config.bucket_name, key)
    self.delete_files(StorageConfig.config.bucket_name, files)
    true
  end

  def delete_generated_files(key)
    if key.empty?
      return false
    end
    files = self.get_file_list(StorageConfig.config.image_bucket_name, key)
    self.delete_files(StorageConfig.config.image_bucket_name, files)
    true
  end

  def get_slide_download_url(key)
    self.get_download_url(StorageConfig.config.bucket_name, key)
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
