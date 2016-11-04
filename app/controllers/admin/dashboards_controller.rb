module Admin
  class DashboardsController < Admin::BaseController
    def index
      @slide_count = Slide.count
      @user_count = User.count
      @conversion_failed_count = Slide.failed.count
      @comment_count = Comment.count

      s = Slide.arel_table
      rec = Slide.select([s[:page_view].sum.as('page_view'), s[:download_count].sum.as('download_count'), s[:embedded_view].sum.as('embedded_view')]).all[0]
      @page_view = rec.page_view
      @download_count = rec.download_count
      @embedded_view = rec.embedded_view

      @latest_slides = Slide.latest_slides
      @popular_slides = Slide.popular_slides
    end
  end
end
