module Admin
  class SlidesController < Admin::BaseController
    include SlideUtil
    before_action :set_slide, only: [:edit, :download]

    def index
      ransack_params = params[:q]
      @q = Slide.search(ransack_params)
      @slides = @q.result(distinct: true).
                latest.
                paginate(page: params[:page], per_page: 20)
    end

    def edit
    end

    def download
      download_slide
    end

    def update
      params.permit! # It's OK because of admin
      @slide = Slide.find(params[:slide][:id])
      @slide.assign_attributes(params[:slide])
      if @slide.update_attributes(params[:slide])
        redirect_to "/admin/slides/#{@slide.id}/edit"
      else
        render :edit
      end
    end

    private

      def set_slide
        @slide = Slide.find(params[:id])
      end
  end
end
