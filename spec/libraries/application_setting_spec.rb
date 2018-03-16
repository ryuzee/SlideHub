require 'rails_helper'

describe 'ApplicationSetting' do
  describe 'load keys' do
    it 'returns array' do
      expect(ApplicationSetting.keys.instance_of?(Array)).to eq(true)
    end
  end

  describe 'get value' do
    it 'returns value' do
      expect(ApplicationSetting['site.name']).to eq('SlideHub')
    end
  end

  describe 'set value' do
    it 'sets value' do
      ApplicationSetting['site.theme'] = 'dark'
      expect(ApplicationSetting['site.theme']).to eq('dark')
    end
  end
end
