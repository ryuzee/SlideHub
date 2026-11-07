class SlideSearch
  include ActiveModel::Model
  attr_reader :search, :slides

  # auth_object: 管理画面から使うときは :admin（すべての項目で検索できる。Slide.ransackable_attributes）
  def initialize(ransack_params, auth_object: nil)
    # Hack to delete params can't be used by ransack
    tag_search = ransack_params['tag_search'].split(',') if ransack_params.present? && ransack_params['tag_search'].present?
    ransack_params.delete('tag_search') if ransack_params.present?

    table = tag_search ? Slide.tagged_with(tag_search, any: true) : Slide
    @search = table.ransack(ransack_params, auth_object: auth_object)
    @slides = @search.result(distinct: true)
  end
end
