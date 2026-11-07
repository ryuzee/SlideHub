class LatestController < ApplicationController
  def index
    @slides = Slide.published.latest.includes(:user).
              paginate(page: params[:page], per_page: 20)
    ensure_page_in_range(@slides)
    respond_to do |format|
      format.html
      format.rss
    end
  end
end
