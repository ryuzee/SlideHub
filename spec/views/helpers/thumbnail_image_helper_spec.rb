require 'rails_helper'

RSpec.describe ThumbnailImageHelper, type: :helper do
  before do
    CloudConfig.provider = SlideHub::Cloud::Engine::Aws
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
      expect(helper.thumbnail_image_url(slide)).to start_with '/packs-test/media/images/failed_to_convert_small'
    end

    it 'returns image url for unconverted' do
      slide = FactoryBot.create(:slide)
      slide.convert_status = :unconverted
      expect(helper.thumbnail_image_url(slide)).to start_with '/packs-test/media/images/converting_small'
    end
  end
end
