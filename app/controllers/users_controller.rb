require 'pp'

class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:index]

  def index
    @user = User.find(current_user.id)
    @slides = Slide
      .latest
      .owner(current_user.id)
      .includes(:user)
      .paginate(page: params[:page], per_page: 20)
    @tags = Slide
      .owner(current_user.id)
      .tag_counts_on(:tags).order('count DESC')
  end

  def show
    @user = User.find(params[:id])
    @slides = Slide.published.latest
      .owner(params[:id])
      .includes(:user)
      .paginate(page: params[:page], per_page: 20)
    @tags = Slide.published
      .owner(params[:id])
      .tag_counts_on(:tags).order('count DESC')
  end

  def statistics
    ransack_params = params[:q]
    @q = Slide.search(ransack_params)
    @slides = @q.result(distinct: true)
      .owner(current_user.id)
      .latest
  end
end
