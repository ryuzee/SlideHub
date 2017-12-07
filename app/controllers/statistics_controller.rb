class StatisticsController < ApplicationController
  before_action :authenticate_user!, only: [:index]

  def index
    ransack_params = params[:q]
    @search = Slide.search(ransack_params)
    @slides = @search.result(distinct: true).
              owner(current_user.id).
              latest
  end
end
