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
      expect(helper.thumbnail_image_url(slide)).to start_with '/assets/failed_to_convert_small'
    end

    it 'returns image url for unconverted' do
      slide = FactoryBot.create(:slide)
      slide.convert_status = :unconverted
      expect(helper.thumbnail_image_url(slide)).to start_with '/assets/converting_small'
    end
  end
  describe 'slide_thumbnail_tag' do
    it 'renders a lazy 4:3 thumbnail with a fallback image' do
      slide = FactoryBot.create(:slide, name: 'My <b>Slide</b>')
      tag = Nokogiri::HTML.fragment(helper.slide_thumbnail_tag(slide, class: 'extra')).at('img')
      expect(tag['src']).to eq helper.thumbnail_image_url(slide)
      expect(tag['class']).to eq 'slide-thumbnail extra'
      expect(tag['alt']).to eq 'My Slide'
      expect(tag['loading']).to eq 'lazy'
      expect(tag['data-fallback-src']).to match %r{/assets/no_image-.*\.svg\z}
    end
  end
end
