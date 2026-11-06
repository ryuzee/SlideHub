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
  # 注目のスライドを管理画面で決めた並び順で返す。非公開や未変換のものは飛ばして limit 件まで
  def self.featured(limit = 10)
    ids = FeaturedSlide.ordered.pluck(:slide_id)
    slides = Slide.published.includes(:user).where(id: ids).index_by(&:id)
    ids.filter_map { |id| slides[id] }.first(limit)
  end

  def self.related(category_id, slide_id, limit = 12)
    Slide.published.latest.
      where('category_id = ?', category_id).
      where('id != ?', slide_id).
      limit(limit).
      includes(:user)
  end
end
