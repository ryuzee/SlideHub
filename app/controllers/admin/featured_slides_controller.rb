module Admin
  class FeaturedSlidesController < Admin::BaseController
    def index
      @featured_slides = FeaturedSlide.includes(:slide)
    end

    def new
      @featured_slide = FeaturedSlide.new
    end

    def create
      @featured_slide = FeaturedSlide.new(params.require(:featured_slide).permit(:slide_id))
      if @featured_slide.save
        redirect_to admin_featured_slides_path, notice: t(:featured_slide_was_added)
      else
        render 'new'
      end
    end

    def destroy
      FeaturedSlide.find(params[:id]).destroy
      redirect_to admin_featured_slides_path, notice: t(:featured_slide_was_deleted)
    end
  end
end
