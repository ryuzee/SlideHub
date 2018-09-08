# == Schema Information
#
# Table name: comments
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  slide_id   :integer          not null
#  comment    :text(65535)      not null
#  created_at :datetime         not null
#  updated_at :datetime
#

FactoryBot.define do
  factory :comment_for_slide, class: Comment do
    id { 1 }
    association :user, factory: :another_user, strategy: :build
    slide_id { 1 }
    comment { 'Sushi' }
  end
end
