class FeaturedSlide < ActiveRecord::Base
  belongs_to :slide
  validates :slide_id, uniqueness: true
  validate :exsitence_of_slide_id

  private
    def exsitence_of_slide_id
      errors.add(:slide_id, :inclusion) unless Slide.published.pluck(:id).include?(slide_id)
    end

end
