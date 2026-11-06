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

  # 直近 months か月の月別投稿数（古い月から順）。[[Date(月初), 件数], ...]
  # 月の区切りはアプリのタイムゾーンで数えるので、DB の関数ではなく Ruby で集計する
  def monthly_upload_counts(months: 12, now: Time.zone.now)
    first_month = now.beginning_of_month - (months - 1).months
    counts = Slide.where(created_at: first_month..).pluck(:created_at).
             map { |time| time.in_time_zone.to_date.beginning_of_month }.tally
    (0...months).map do |offset|
      month = (first_month + offset.months).to_date
      [month, counts.fetch(month, 0)]
    end
  end

  # 変換キューに残っているメッセージのおおよその件数。取得できなければ nil
  def queue_length
    CloudConfig.provider.queue_length
  end

  def latest_slides
    SlidesFinder.latest
  end

  def popular_slides
    SlidesFinder.popular
  end
end
