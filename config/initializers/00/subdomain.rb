module Subdomain
  @subdomains = ['www', 'admin', 'slide', 'slidehub', 'main']
  def self.list
    @subdomains
  end
end

additional_str_subdomains = ENV.fetch('OSS_MULTI_TENANT_EXCLUDED_SUBDOMAINS') {''}
additional_subdomains = additional_str_subdomains.split(',')
additional_subdomains.each do |s|
  Subdomain.list.push(s) unless s.blank?
end

