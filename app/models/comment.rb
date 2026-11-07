# == Schema Information
#
# Table name: comments
#
#  id         :integer          not null, primary key
#  comment    :text(65535)      not null
#  created_at :datetime         not null
#  updated_at :datetime
#  slide_id   :integer          not null
#  user_id    :integer          not null
#
class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :slide
  validates :comment, presence: true
  validates :comment, length: { maximum: 2048 }
  default_scope { order('created_at ASC') }
end
