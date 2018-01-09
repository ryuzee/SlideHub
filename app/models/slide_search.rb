class SlideSearch
  include ActiveModel::Model
  attr_reader :search, :slides

  def initialize(ransack_params)
    # Hack to delete params can't be used by ransack
    tag_search = ransack_params['tag_search'].split(',') if ransack_params.present? && ransack_params['tag_search'].present?
    ransack_params.delete('tag_search') if ransack_params.present?

    table = tag_search ? Slide.tagged_with(tag_search, any: true) : Slide
    @search = table.search(ransack_params)
    @slides = @search.result(distinct: true)
  end
end
