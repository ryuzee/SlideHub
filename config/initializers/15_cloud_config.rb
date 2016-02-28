module CloudConfig
  SERVICE = if ENV.has_key?('OSS_USE_AZURE') && ENV['OSS_USE_AZURE'].to_i == 1
              AzureConfig
            else
              AWSConfig
            end

  def self.service_name
    if ENV.has_key?('OSS_USE_AZURE') && ENV['OSS_USE_AZURE'].to_i == 1
      'azure'
    else
      'aws'
    end
  end
end
