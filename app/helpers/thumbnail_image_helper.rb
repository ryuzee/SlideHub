module ThumbnailImageHelper
  def thumbnail_image_url(slide)
    if slide.convert_error?
      image_path('failed_to_convert_small.jpg')
    elsif slide.converted? == false
      image_path('converting_small.jpg')
    else
      slide.thumbnail.url
    end
  end
end
