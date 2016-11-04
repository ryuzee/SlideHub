module SlideUtil
  extend ActiveSupport::Concern

  def download_slide
    url = CloudConfig::SERVICE.get_slide_download_url(@slide.key)
    # @TODO: handle response code
    require 'open-uri'
    data = open(url).read
    send_data data, disposition: 'attachment', filename: "#{@slide.key}#{@slide.extension}"
  end
end
