module SlideUtil
  extend ActiveSupport::Concern

  def set_slide
    @slide = Slide.find(params[:id])
  end

  def download_slide
    url = CloudConfig::PROVIDER_ENGINE.get_slide_download_url(@slide.object_key)
    begin
      require 'open-uri'
      data = URI.parse(url).open.read
      send_data data, disposition: 'attachment', filename: "#{@slide.object_key}#{@slide.extension}"
    rescue StandardError
      render 'errors/404', status: :not_found
    end
  end

  def slide_position
    position = 1
    position = params[:page].to_i if params.key?(:page) && params[:page].to_i.positive?
    position
  end
end
