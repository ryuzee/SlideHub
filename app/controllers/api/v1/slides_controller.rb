module Api
  # :reek:UncommunicativeModuleName { enabled: false }
  module V1
    class SlidesController < Api::V1::BaseController
      def index
        @slides = Slide.all.published.latest.includes(:user).includes(:category)
        if params['name']
          @slides = @slides.where('name like ?', "%#{params["name"]}%")
        elsif params[:tag]
          @slides = @slides.tagged_with(params[:tag])
        end
      end

      def show
        @slide = Slide.where(id: params[:id]).published.includes(:user).includes(:category).first
        unless @slide
          not_found
        end
      end

      def transcript
        @slide = Slide.where(id: params[:id]).published.includes(:user).includes(:category).first
        unless @slide
          not_found
        end
      end
    end
  end
end
