class SlideIndex
  include ActiveModel::Model

  def latest_slides
    @latest_slides ||= SlidesFinder.latest(8)
  end

  def popular_slides
    @popular_slides ||= SlidesFinder.popular(8)
  end

  def featured_slides
    @featured_slides ||= SlidesFinder.featured(4)
  end
end
