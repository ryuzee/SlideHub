# == Schema Information
#
# Table name: featured_slides
#
#  id         :integer          not null, primary key
#  slide_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class FeaturedSlide < ApplicationRecord
  belongs_to :slide
  validates :slide_id, uniqueness: true
  validate :exsitence_of_slide_id

  private

    def exsitence_of_slide_id
      errors.add(:slide_id, :inclusion) unless Slide.published.pluck(:id).include?(slide_id)
    end
end
