class Thumbnail
  attr_accessor :object_key

  def initialize(object_key)
    @object_key = object_key
  end

  def url
    "#{CloudConfig::provider.resource_endpoint}/#{object_key}/thumbnail.jpg"
  end

  def url_middle
    "#{CloudConfig::provider.resource_endpoint}/#{object_key}/thumbnail-middle.jpg"
  end
end
