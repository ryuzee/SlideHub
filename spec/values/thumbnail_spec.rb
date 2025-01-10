require 'rails_helper'

describe 'Thumbnail' do
  before do
    CloudConfig.class_eval { remove_const(:PROVIDER_ENGINE) }
    CloudConfig::PROVIDER_ENGINE = SlideHub::Cloud::Engine::Aws
    CloudHelpers.switch_to_aws
  end

  describe 'Method "url"' do
    it 'returns valid url' do
      thumbnail = Thumbnail.new('an-object-key')
      expect(thumbnail.url).to eq('https://my-image-bucket.s3-ap-northeast-1.amazonaws.com/an-object-key/thumbnail.jpg')
    end
  end
end

describe 'Slide_on_Azure' do
  before do
    CloudConfig.class_eval { remove_const(:PROVIDER_ENGINE) }
    CloudConfig::PROVIDER_ENGINE = SlideHub::Cloud::Engine::Azure
    CloudHelpers.switch_to_azure
  end

  describe 'Method "url"' do
    it 'returns valid url' do
      thumbnail = Thumbnail.new('an-object-key')
      expect(thumbnail.url).to eq('https://azure_test.blob.core.windows.net/my-image-bucket/an-object-key/thumbnail.jpg')
    end
  end
end
