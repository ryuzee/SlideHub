class SlidesFinder
  def self.latest(limit = 10)
    Slide.published.latest.
      includes(:user).
      limit(limit)
  end

  def self.popular(limit = 10)
    Slide.published.popular.
      includes(:user).
      limit(limit)
  end

  # :reek:UncommunicativeVariableName { enabled: false }
  def self.featured(limit = 10)
    ids = FeaturedSlide.order(created_at: 'desc').pluck(:slide_id)
    slides = Slide.published.
             includes(:user).
             where(id: ids).
             limit(limit)
    ids.collect { |id| slides.detect { |x| x.id == id.to_i } }
  end

  def self.related(category_id, slide_id, limit = 12)
    Slide.published.latest.
      where('category_id = ?', category_id).
      where('id != ?', slide_id).
      limit(limit).
      includes(:user)
  end
end
