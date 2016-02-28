module CloudConfig
  if ENV.has_key?('OSS_USE_AZURE') && ENV['OSS_USE_AZURE'].to_i == 1
    SERVICE = AzureConfig
  else
    SERVICE = AWSConfig
  end

  def service_name
    if ENV.has_key?('OSS_USE_AZURE') && ENV['OSS_USE_AZURE'].to_i == 1
      'azure'
    else
      'aws'
    end
  end
end
