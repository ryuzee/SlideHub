module PageImagesHelper
  def slide_page_image_list_tag(slide)
    result = ''
    default_image = asset_pack_url('media/images/loading.jpg')

    if slide.pages.list.try(:count).positive?
      idx = 0
      slide.pages.list.each do |page|
        original_image = "#{CloudConfig::provider.resource_endpoint}/#{page}"
        if idx.zero?
          default_image = original_image
        end
        result += "<li><img class=\"lazy\" src=\"#{asset_pack_url("media/images/spacer.png")}\" data-original=\"#{original_image}\" /></li>"
        idx += 1
      end
    elsif slide.convert_error?
      default_image = asset_pack_url('media/images/failed_to_convert.jpg')
      result = "<li><img class=\"lazy\" data-original=\"#{default_image}\" /></li>"
    else
      default_image = asset_pack_url('media/images/converting.jpg')
      result = "<li><img class=\"lazy\" data-original=\"#{default_image}\" /></li>"
    end
    result
  end
end
