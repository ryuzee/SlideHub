require 'rails_helper'

describe 'Tenant' do
  let(:tenant) { build(:default_tenant) }

  describe 'valid tenantnames' do
    it 'can be accepted' do
      valid_tenantnames = %w[
        ryuzee
        ryuzee1234
        RYUZEE
        ryu
      ]
      expect(tenant).to allow_value(*valid_tenantnames).for(:name)
    end
  end

  describe 'invalid tenantnames' do
    it 'can not be accepted' do
      invalid_tenantnames = [
        'ryuzee@example.com',
        '-ryuzee',
        'ryuzee-',
        'ryu zee',
        'ry',
        'ryuzee789012345678901234567890123',
        'a#b',
        'a' * (32 + 1),
        'admin',
        'www',
        'users',
        'categories',
        'popular',
        'latest',
        'statistics',
        'dashboard',
        'dashboards',
        'api',
        'www',
        'blog',
        'image',
        'rss',
      ]
      expect(tenant).not_to allow_value(*invalid_tenantnames).for(:name)
    end
  end

  describe 'Creating "Tenant" model' do
    success_data = { name: 'dummy1' }
    it 'is valid with name' do
      tenant = Tenant.new(success_data)
      expect(tenant.valid?).to eq(true)
      expect(tenant.save).to eq(true)
    end

    it 'is invalid without name' do
      data = success_data.dup
      data.delete(:name)
      tenant = Tenant.new(data)
      expect(tenant.valid?).to eq(false)
    end

    it 'is invalid with a tenantname that is already used by others' do
      default_tenant = FactoryBot.create(:default_tenant)
      data = success_data.dup
      data[:name] = default_tenant[:name]
      tenant = Tenant.new(data)
      expect(tenant.valid?).to eq(false)
    end
  end
end
