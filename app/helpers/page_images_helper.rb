module PageImagesHelper
  def slide_page_image_list_tag(slide)
    result = ''
    default_image = image_url("loading.jpg")

    if slide.pages.list.try(:count) > 0
      idx = 0
      slide.pages.list.each do |f|
        u = "#{CloudConfig::SERVICE.resource_endpoint}/#{f}"
        if idx == 0
          default_image = u
        end
        result += "<li><img class=\"lazy\" src=\"#{image_url("spacer.png")}\" data-original=\"#{u}\" /></li>"
        idx += 1
      end
    elsif slide.convert_error?
      default_image = image_url("failed_to_convert.jpg")
      result = "<li><img class=\"lazy\" data-original=\"#{default_image}\" /></li>"
    else
      default_image = image_url("converting.jpg")
      result = "<li><img class=\"lazy\" data-original=\"#{default_image}\" /></li>"
    end
    result
  end
end
