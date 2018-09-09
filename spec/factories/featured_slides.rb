# == Schema Information
#
# Table name: featured_slides
#
#  id         :integer          not null, primary key
#  slide_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :featured_slide do
    slide_id { 1 }
  end
end
