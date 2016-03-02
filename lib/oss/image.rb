require 'rubygems'
require 'rmagick'

module Oss
  class Image
    def thumbnail(src, dest)
      w = 320
      h = 240

      thumb = Magick::Image.from_blob(File.read(src)).shift
      thumb_out = if thumb.columns < w || thumb.rows < h
                    cover_white(thumb, w, h)
                  else
                    shrink_to_fill(thumb, w, h)
                  end
      thumb_out.write(dest)
    end

    private

      def shrink_to_fill(image, width, height)
        image.resize_to_fill!(width, height)
        image
      end

      def cover_white(image, width, height)
        new_width = (image.columns < width) ? image.columns : width
        new_height = (image.rows < height) ? image.rows : height

        image.resize_to_fit!(new_width, new_height)
        image_out = Magick::Image.new(width, height)
        image_out.background_color = '#ffffff'
        image_out.composite!(image, Magick::CenterGravity, Magick::OverCompositeOp)
        image_out
      end
  end
end
