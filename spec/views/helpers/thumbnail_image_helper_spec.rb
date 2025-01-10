require 'rails_helper'

RSpec.describe ThumbnailImageHelper, type: :helper do
  before do
    CloudConfig.class_eval { remove_const(:PROVIDER_ENGINE) }
    CloudConfig::PROVIDER_ENGINE = SlideHub::Cloud::Engine::Aws
    CloudHelpers.switch_to_aws
  end

  describe 'thumbnail_image_url' do
    it 'returns thumbnail url on AWS S3' do
      slide = FactoryBot.create(:slide)
      expect(helper.thumbnail_image_url(slide)).to start_with 'https://my-image-bucket.s3-ap-northeast-1.amazonaws.com/'
      expect(helper.thumbnail_image_url(slide)).to end_with '/thumbnail.jpg'
    end

    it 'returns image url for convert_error' do
      slide = FactoryBot.create(:slide)
      slide.convert_status = :convert_error
      expect(helper.thumbnail_image_url(slide)).to start_with '/assets/failed_to_convert_small'
    end

    it 'returns image url for not_converted' do
      slide = FactoryBot.create(:slide)
      slide.convert_status = :not_converted
      expect(helper.thumbnail_image_url(slide)).to start_with '/assets/converting_small'
    end
  end
end
