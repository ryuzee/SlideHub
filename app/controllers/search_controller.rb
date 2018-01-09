class SearchController < ApplicationController
  def index
    slide_search = SlideSearch.new(params[:q])
    @search = slide_search.search
    @slides = slide_search.slides.latest.paginate(page: params[:page], per_page: 20)
  end
end
