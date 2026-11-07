class CommentsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :destroy]

  # 投稿先のスライドが無ければ 404。保存できなかったときは、理由を添えてスライドの画面に戻す
  def create
    slide = Slide.find(params.require(:comment)[:slide_id])
    comment = slide.comments.new(params.require(:comment).permit(:comment))
    comment.user = current_user
    unless comment.save
      flash[:alert] = ERB::Util.html_escape(comment.errors.full_messages.unshift(t(:comment_not_posted)).join(' '))
    end
    redirect_to slide_path(slide.id, anchor: 'comments-heading')
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
