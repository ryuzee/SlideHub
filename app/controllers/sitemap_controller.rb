class SitemapController < ApplicationController
  def index
    @slides = Slide.published.latest
    @categories = Category.order('id asc')
    @users = User.where(id: Slide.published.select(:user_id))

    respond_to do |format|
      format.xml
    end
  end
end
