# :reek:UtilityFunction { enabled: false }
class Dashboard
  include ActiveModel::Model

  # :reek:FeatureEnvy { enabled: false }
  def initialize
    slide_table = Slide.arel_table
    @summary ||= Slide.select(
      [slide_table[:page_view].sum.as('page_view'),
       slide_table[:download_count].sum.as('download_count'),
       slide_table[:embedded_view].sum.as('embedded_view')],
    ).all[0]
  end

  def slide_count
    Slide.count
  end

  def user_count
    User.count
  end

  def conversion_failed_count
    Slide.failed.count
  end

  def comment_count
    Comment.count
  end

  def page_view
    @summary.page_view
  end

  def download_count
    @summary.download_count
  end

  def embedded_view
    @summary.embedded_view
  end

  def latest_slides
    Slide.latest_slides
  end

  def popular_slides
    Slide.popular_slides
  end
end
