module Admin
  class SlidesController < Admin::BaseController
    include SlideUtil
    before_action :set_slide, only: [:edit, :update, :download]

    def index
      slide_search = SlideSearch.new(params[:q])
      @search = slide_search.search
      @slides = slide_search.slides.latest.paginate(page: params[:page], per_page: 20)
    end

    def edit; end

    def download
      download_slide
    end

    def update
      params.permit! # It's OK because of admin
      if @slide.update_attributes(params[:slide])
        redirect_to "/admin/slides/#{@slide.id}/edit", notice: t(:slide_was_updated)
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
