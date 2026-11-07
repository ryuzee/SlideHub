require 'rails_helper'

describe 'Subdomain' do
  describe 'list' do
    it 'includes the reserved subdomains' do
      expect(SlideHub::Subdomain.list.is_a?(Array)).to eq(true)
      expect(SlideHub::Subdomain.list.include?('mysql')).to eq(true)
    end
  end

  describe 'load' do
    it 'adds the subdomains excluded by the environment variable' do
      orig = ENV.fetch('OSS_MULTI_TENANT_EXCLUDED_SUBDOMAINS') { '' }
      ENV['OSS_MULTI_TENANT_EXCLUDED_SUBDOMAINS'] = 'aaa,bbb'
      begin
        SlideHub::Subdomain.load
        expect(SlideHub::Subdomain.list.include?('aaa')).to eq(true)
        expect(SlideHub::Subdomain.list.include?('bbb')).to eq(true)
      ensure
        ENV['OSS_MULTI_TENANT_EXCLUDED_SUBDOMAINS'] = orig
      end
    end
  end
end
