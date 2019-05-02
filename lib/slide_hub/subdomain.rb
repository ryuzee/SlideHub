module SlideHub
  module Subdomain
    @subdomains = %w[www admin slide slidehub main mysql information_schema]

    def self.list
      @subdomains
    end

    def self.load
      ENV.fetch('OSS_MULTI_TENANT_EXCLUDED_SUBDOMAINS') { '' }.split(',').each do |domain|
        @subdomains.push(domain) if domain.present?
      end
    end
  end
end
