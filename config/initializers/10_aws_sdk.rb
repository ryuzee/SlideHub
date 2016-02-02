if (not AWSConfig.config.aws_access_id.blank?) && (not AWSConfig.config.aws_secret_key.blank?)
  Aws.config.update({
    region: AWSConfig.config.region,
    credentials: Aws::Credentials.new(AWSConfig.config.aws_access_id, AWSConfig.config.aws_secret_key),
  },)
end
