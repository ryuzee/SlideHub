if (ENV.has_key?('OSS_AWS_ACCESS_ID') && !ENV['OSS_AWS_ACCESS_ID'].empty? &&
    ENV.has_key?('OSS_AWS_SECRET_KEY') && !ENV['OSS_AWS_SECRET_KEY'].empty?) then
  Aws.config.update({
    region: ENV['OSS_REGION'],
    credentials: Aws::Credentials.new(ENV['OSS_AWS_ACCESS_ID'], ENV['OSS_AWS_SECRET_KEY']),
  })
end
