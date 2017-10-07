# == Schema Information
#
# Table name: featured_slides
#
#  id         :integer          not null, primary key
#  slide_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

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
    end
  end
end
