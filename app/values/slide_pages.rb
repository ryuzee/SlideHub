class SlidePages
  attr_accessor :object_key
  attr_accessor :num_of_pages

  def initialize(object_key, num_of_pages)
    @object_key = object_key
    @num_of_pages = num_of_pages
  end

  def url
    "#{CloudConfig::SERVICE.resource_endpoint}/#{object_key}/list.json"
  end

  def list
    len = num_of_pages.abs.to_s.length
    result = []
    (1..num_of_pages).each do |page_number|
      result.push("#{object_key}/slide-#{format_page_number(page_number, len)}.jpg")
    end
    result
  end

  private

    # :reek:UtilityFunction
    def format_page_number(number, length)
      number.to_s.rjust(length, '0')
    end
end
