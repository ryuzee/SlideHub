require 'pp'

class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:index]

  def index
    @user = User.find(current_user.id)
    @slides = Slide
      .where('user_id = ?', current_user.id)
      .includes(:user)
      .order("created_at desc")
      .paginate(page: params[:page], per_page: 20)
    @tags = Slide
      .where('user_id = ?', current_user.id)
      .tag_counts_on(:tags).order('count DESC')
  end

  def show
    @user = User.find(params[:id])
    @slides = Slide.where('convert_status = 100')
      .where('user_id = ?', params[:id])
      .order("created_at desc")
      .includes(:user)
      .paginate(page: params[:page], per_page: 20)
    @tags = Slide.where('convert_status = 100')
      .where('user_id = ?', params[:id])
      .tag_counts_on(:tags).order('count DESC')
  end

  def statistics
    ransack_params = params[:q]
    @q = Slide.search(ransack_params)
    @slides = @q.result(distinct: true)
      .where('user_id = ?', current_user.id)
      .order('created_at desc')
  end
end
