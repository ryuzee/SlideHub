# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  user_id          :integer          not null
#  slide_id   :integer          not null
#  comment          :text(65535)      not null
#  created_at       :datetime         not null
#  modified_at      :datetime
#

FactoryGirl.define do
  factory :comment_for_slide, class: Comment do
    id 1
    user_id 998
    slide_id 1
    comment 'Sushi'
  end
end
