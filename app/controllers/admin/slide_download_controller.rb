module Admin
  class SlideDownloadController < Admin::BaseController
    include SlideUtil
    before_action :set_slide, only: [:show]

    def show
      download_slide
    end

    private

      def set_slide
        @slide = Slide.find(params[:id])
      end
  end
end
