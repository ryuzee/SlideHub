class SlidePages
  attr_accessor :object_key, :num_of_pages, :image_format

  # image_format はページ画像の拡張子。前に変換したスライドは jpg、今は webp で変換する
  def initialize(object_key, num_of_pages, image_format = 'jpg')
    @object_key = object_key
    @num_of_pages = num_of_pages
    @image_format = image_format
  end

  def url
    "#{CloudConfig.provider.resource_endpoint}/#{object_key}/list.json"
  end

  def list
    len = num_of_pages.abs.to_s.length
    result = []
    (1..num_of_pages).each do |page_number|
      result.push("#{object_key}/slide-#{format_page_number(page_number, len)}.#{image_format}")
    end
    result
  end

  private

    # :reek:UtilityFunction
    def format_page_number(number, length)
      number.to_s.rjust(length, '0')
    end
end
