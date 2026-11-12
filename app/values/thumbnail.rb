class Thumbnail
  attr_accessor :object_key, :image_format

  # image_format はサムネイルの拡張子。前に変換したスライドは jpg、今は webp で変換する
  def initialize(object_key, image_format = 'jpg')
    @object_key = object_key
    @image_format = image_format
  end

  def url
    file_url('thumbnail')
  end

  def url_wide
    file_url('thumbnail-16x9')
  end

  def url_middle
    file_url('thumbnail-middle')
  end

  private

    def file_url(name)
      "#{CloudConfig.provider.resource_endpoint}/#{object_key}/#{name}.#{image_format}"
    end
end
