module Subdomain
  @subdomains = %w[www admin slide slidehub main mysql information_schema]
  def self.list
    @subdomains
  end
end

additional_str_subdomains = ENV.fetch('OSS_MULTI_TENANT_EXCLUDED_SUBDOMAINS') { '' }
additional_subdomains = additional_str_subdomains.split(',')
additional_subdomains.each do |s|
  Subdomain.list.push(s) if s.present?
end
