class CommentsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :destroy]

  def create
    comment = params.require(:comment).permit(:comment, :user_id, :commentable_id, :commentable_type)
    @comment = Comment.new(comment)
    @comment.user_id = current_user.id
    if @comment.save
      redirect_to "/slides/#{params[:comment][:commentable_id]}"
    else
      # @TODO: show error message...
      redirect_to "/slides/#{params[:comment][:commentable_id]}"
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    id = @comment.commentable_id
    if @comment.user_id = current_user.id
      @comment.destroy
    end
    redirect_to "/slides/#{id}"
  end
end
