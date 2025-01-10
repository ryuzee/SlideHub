require 'rails_helper'

describe 'Slide' do
  before do
    CloudConfig.class_eval { remove_const(:PROVIDER_ENGINE) }
    CloudConfig::PROVIDER_ENGINE = SlideHub::Cloud::Engine::Aws
    CloudHelpers.switch_to_aws
  end

  describe 'Method "url"' do
    it 'returns valid url' do
      slide_pages = SlidePages.new('an-object-key', 10)
      expect(slide_pages.url).to eq('https://my-image-bucket.s3-ap-northeast-1.amazonaws.com/an-object-key/list.json')
    end
  end

  describe 'Method "page_list"' do
    it 'returns page list (1 page)' do
      slide_pages = SlidePages.new('an-object-key', 1)
      expect(slide_pages.list).to eq(['an-object-key/slide-1.jpg'])
    end

    it 'returns page list (10 page)' do
      slide_pages = SlidePages.new('a', 10)
      expected = ['a/slide-01.jpg', 'a/slide-02.jpg', 'a/slide-03.jpg',
                  'a/slide-04.jpg', 'a/slide-05.jpg', 'a/slide-06.jpg',
                  'a/slide-07.jpg', 'a/slide-08.jpg', 'a/slide-09.jpg', 'a/slide-10.jpg']
      expect(slide_pages.list).to eq(expected)
    end
  end
end

describe 'Slide_on_Azure' do
  before do
    CloudConfig.class_eval { remove_const(:PROVIDER_ENGINE) }
    CloudConfig::PROVIDER_ENGINE = SlideHub::Cloud::Engine::Azure
    CloudHelpers.switch_to_azure
  end

  describe 'Method "page_list_url"' do
    it 'returns valid url' do
      slide_pages = SlidePages.new('an-object-key', 1)
      expect(slide_pages.url).to eq('https://azure_test.blob.core.windows.net/my-image-bucket/an-object-key/list.json')
    end
  end
end
