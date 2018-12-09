class StatisticsController < ApplicationController
  before_action :authenticate_user!, only: [:index]

  def index
    ransack_params = params[:q]
    @search = Slide.ransack(ransack_params)
    @slides = @search.result(distinct: true).
              owner(current_user.id).
              latest
    respond_to do |format|
      format.html
      format.csv
    end
  end
end
