# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  user_id          :integer          not null
#  commentable_id   :integer          not null
#  comment          :text(65535)      not null
#  created_at       :datetime         not null
#  modified_at      :datetime
#  commentable_type :string(255)      default("Slide")
#  role             :string(255)      default("comments")
#

FactoryGirl.define do
  factory :comment_for_slide, class: Comment do
    id 1
    user_id 1
    commentable_id 1
    comment 'Sushi'
    commentable_type 'Slide'
  end
end
