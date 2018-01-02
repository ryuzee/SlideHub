module Admin
  class SlidesController < Admin::BaseController
    include SlideUtil
    before_action :set_slide, only: [:edit, :update, :download]

    def index
      ransack_params = params[:q]
      @search = Slide.search(ransack_params)
      @slides = @search.result(distinct: true).
                latest.
                paginate(page: params[:page], per_page: 20)
    end

    def edit; end

    def download
      download_slide
    end

    def update
      params.permit! # It's OK because of admin
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
