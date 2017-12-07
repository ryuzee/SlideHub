class SlideIndex
  include ActiveModel::Model

  def latest_slides
    @latest_slides ||= Slide.latest_slides(8)
  end

  def popular_slides
    @popular_slides ||= Slide.popular_slides(8)
  end

  def featured_slides
    @featured_slides ||= Slide.featured_slides(4)
  end
end
