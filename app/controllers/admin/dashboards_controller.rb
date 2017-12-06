module Admin
  class DashboardsController < Admin::BaseController
    def index
      @slide_count = Slide.count
      @user_count = User.count
      @conversion_failed_count = Slide.failed.count
      @comment_count = Comment.count

      slide_table = Slide.arel_table
      summary = Slide.select([slide_table[:page_view].sum.as('page_view'), slide_table[:download_count].sum.as('download_count'), slide_table[:embedded_view].sum.as('embedded_view')]).all[0]
      @page_view = summary.page_view
      @download_count = summary.download_count
      @embedded_view = summary.embedded_view

      @latest_slides = Slide.latest_slides
      @popular_slides = Slide.popular_slides
    end
  end
end
