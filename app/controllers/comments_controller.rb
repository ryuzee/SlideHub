# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  user_id          :integer          not null
#  commentable_id   :integer          not null
#  comment          :text(65535)      not null
#  created_at       :datetime         not null
#  updated_at       :datetime
#  commentable_type :string(255)      default("Slide")
#  role             :string(255)      default("comments")
#

class CommentsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :destroy]

  def create
    comment = params.require(:comment).permit(:comment, :user_id, :slide_id)
    @comment = Comment.new(comment)
    @comment.user_id = current_user.id
    unless @comment.save
      # @TODO: show error message...
    end
    redirect_to slide_path(params[:comment][:slide_id])
  end

  def destroy
    @comment = Comment.find(params[:id])
    slide_id = @comment.slide_id
    if @comment.user_id == current_user.id
      @comment.destroy
    end
    redirect_to slide_path(slide_id)
  end
end
