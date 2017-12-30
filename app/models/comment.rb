# == Schema Information
#
# Table name: comments
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  slide_id    :integer          not null
#  comment     :text(65535)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime
#

class Comment < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :slide, optional: true
  validates :comment, presence: true
  validates :comment, length: { maximum: 2048 }
  default_scope { order('created_at ASC') }
end
