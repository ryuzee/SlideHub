require 'rails_helper'

describe 'FeaturedSlide' do
  describe 'Creating "FeaturedSlide" model' do
    it 'is valid with existing slide' do
      slide = create(:slide)
      success_data = { slide_id: slide.id }
      featured_slide = FeaturedSlide.new(success_data)
      expect(featured_slide.valid?).to eq(true)
    end

    it 'is invalid without existing slide' do
      failed_data = { slide_id: 123456 }
      featured_slide = FeaturedSlide.new(failed_data)
      expect(featured_slide.valid?).to eq(false)
      # 管理画面にはエラーをまとめて出すので、同じことを 2 回言わない
      expect(featured_slide.errors.full_messages.size).to eq(1)
    end
  end

  describe 'ordering' do
    it 'puts a newly added slide at the top' do
      first = create(:featured_slide)
      second = create(:featured_slide)
      expect(FeaturedSlide.ordered.to_a).to eq([second, first])
    end

    it 'reorders by the given ids and keeps the others after them' do
      a = create(:featured_slide)
      b = create(:featured_slide)
      c = create(:featured_slide)
      FeaturedSlide.reorder_by_ids([a.id.to_s, c.id.to_s])
      expect(FeaturedSlide.ordered.pluck(:id)).to eq([a.id, c.id, b.id])
    end

    it 'expires the cached featured slides on the top page' do
      a = create(:featured_slide)
      allow(Rails.cache).to receive(:delete)
      expect(Rails.cache).to receive(:delete).with('views/featured_slides/ja').at_least(:once)
      expect(Rails.cache).to receive(:delete).with('views/featured_slides/en').at_least(:once)
      FeaturedSlide.reorder_by_ids([a.id])
    end
  end

  describe 'SlidesFinder.featured' do
    it 'returns published slides in the configured order, skipping private ones, up to the limit' do
      a = create(:featured_slide)
      # 注目に入れた後で非公開にされたスライド
      hidden = create(:featured_slide)
      hidden.slide.update!(private: true)
      b = create(:featured_slide)
      c = create(:featured_slide)
      FeaturedSlide.reorder_by_ids([b.id, hidden.id, a.id, c.id])
      expect(SlidesFinder.featured(2)).to eq([b.slide, a.slide])
    end
  end
end
