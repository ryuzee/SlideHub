if (!ENV['OSS_AWS_ACCESS_ID'].empty? && !ENV['OSS_AWS_SECRET_KEY'].empty?)
  Aws.config.update({
    region: ENV['OSS_REGION'],
    credentials: Aws::Credentials.new(ENV['OSS_AWS_ACCESS_ID'], ENV['OSS_AWS_SECRET_KEY']),
  })
end
