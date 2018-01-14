module Admin
  class SlideReconvertController < Admin::BaseController
    before_action :set_slide, only: [:show]

    def show
      @slide.send_convert_request
      redirect_to admin_slides_path, notice: t(:send_convert_request_completed)
    end

    private

      def set_slide
        @slide = Slide.find(params[:id])
      end
  end
end
