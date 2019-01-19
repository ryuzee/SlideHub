class SlidePages
  include WebResource

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
    (1..num_of_pages).each do |i|
      n = i.to_s.rjust(len, '0')
      result.push("#{object_key}/slide-#{n}.jpg")
    end
    result
  end
end
