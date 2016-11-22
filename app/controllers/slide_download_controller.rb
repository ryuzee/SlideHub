class SlideDownloadController < ApplicationController
  include SlideUtil
  before_action :set_slide
  before_action :downloadable?

  def show
    @slide.increment(:download_count).save
    download_slide
  end

  private

    def downloadable?
      redirect_to slide_path(@slide.id) if @slide.downloadable != true
    end
end
