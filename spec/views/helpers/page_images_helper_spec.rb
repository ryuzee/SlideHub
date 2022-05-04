require 'rails_helper'

RSpec.describe PageImagesHelper, type: :helper do
  before do
    CloudConfig.class_eval { remove_const(:PROVIDER_ENGINE) }
    CloudConfig::PROVIDER_ENGINE = SlideHub::Cloud::Engine::AWS
    CloudHelpers.switch_to_aws
  end

  describe 'list_tag' do
    it 'returns tag that include actual images' do
      slide = FactoryBot.create(:slide)
      tag = helper.slide_page_image_list_tag(slide)
      expect(tag).to match(%r{<li><img class="lazy" src="http://test.host/assets/spacer-(.*).png" data-original="https://my-image-bucket.s3-ap-northeast-1.amazonaws.com/(.*)/slide-1.jpg" /></li>})
    end

    it 'returns tag that indicate conversion failure' do
      slide = FactoryBot.create(:slide)
      slide.convert_status = :convert_error
      slide.num_of_pages = 0
      slide.save!
      tag = helper.slide_page_image_list_tag(slide)
      expect(tag).to match(%r{<li><img class="lazy" data-original="http://test.host/assets/failed_to_convert-(.*).jpg" /></li>})
    end

    it 'returns tag that indicate converting' do
      slide = FactoryBot.create(:slide)
      slide.convert_status = :not_converted
      slide.num_of_pages = 0
      slide.save!
      tag = helper.slide_page_image_list_tag(slide)
      expect(tag).to match(%r{<li><img class="lazy" data-original="http://test.host/assets/converting-(.*).jpg" /></li>})
    end
  end
end
