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

    it 'uses the 16:9 thumbnail and falls back to the 4:3 one when the site setting is 16:9' do
      ApplicationSetting['site.thumbnail_aspect_ratio'] = '16:9'
      slide = FactoryBot.create(:slide)
      tag = Nokogiri::HTML.fragment(helper.slide_thumbnail_tag(slide)).at('img')
      expect(tag['src']).to eq slide.thumbnail.url_wide
      expect(tag['class']).to eq 'slide-thumbnail slide-thumbnail-16x9'
      fallbacks = tag['data-fallback-src'].split
      expect(fallbacks.first).to eq slide.thumbnail.url
      expect(fallbacks.last).to match %r{/assets/no_image-.*\.svg\z}
    ensure
      ApplicationSetting['site.thumbnail_aspect_ratio'] = '4:3'
    end

    it 'keeps the converting image for unconverted slides even when the setting is 16:9' do
      ApplicationSetting['site.thumbnail_aspect_ratio'] = '16:9'
      slide = FactoryBot.create(:slide, convert_status: Slide.convert_statuses[:unconverted])
      tag = Nokogiri::HTML.fragment(helper.slide_thumbnail_tag(slide)).at('img')
      expect(tag['src']).to start_with '/assets/converting_small'
      expect(tag['class']).to eq 'slide-thumbnail slide-thumbnail-16x9'
    ensure
      ApplicationSetting['site.thumbnail_aspect_ratio'] = '4:3'
    end
  end
end
