class SearchController < ApplicationController
  def index
    ransack_params = params[:q]
    # Hack to delete params can't be used by ransack
    tag_search = ransack_params['tag_search'].split(',') if ransack_params.present? && ransack_params['tag_search'].present?
    ransack_params.delete('tag_search') if ransack_params.present?

    table = tag_search ? Slide.tagged_with(tag_search, any: true) : Slide
    @search = table.search(ransack_params)
    @slides = @search.result(distinct: true).
              published.latest.
              includes(:user).
              paginate(page: params[:page], per_page: 20)
  end
end
