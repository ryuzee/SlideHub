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

class Comment < ActiveRecord::Base
  include ActsAsCommentable::Comment

  belongs_to :commentable, polymorphic: true

  default_scope -> { order('created_at ASC') }

  # NOTE: install the acts_as_votable plugin if you
  # want user to vote on the quality of comments.
  # acts_as_voteable

  # NOTE: Comments belong to a user
  belongs_to :user

  validates :comment, presence: true
  validates :comment, length: { maximum: 2048 }
end
