class CategoriesController < ApplicationController
  def show
    @slides = Slide.published.latest.category(params[:id]).includes(:user).
              paginate(page: params[:page], per_page: 20)

    @category = Category.find(params[:id])
    ensure_page_in_range(@slides)
  end
end
