require 'rubygems'
require 'rmagick'

module SlideHub
  class Image
    # 一覧用サムネイルのファイル名と大きさ。サイト設定 site.thumbnail_aspect_ratio で表示する方を選ぶ
    LIST_THUMBNAILS = {
      'thumbnail.jpg' => { width: 320, height: 240 },
      'thumbnail-16x9.jpg' => { width: 480, height: 270 },
    }.freeze

    # 1ページ目の画像から一覧用サムネイル（4:3 と 16:9）を同じディレクトリに作り、作ったファイルのパスを返す
    def list_thumbnails(first_page)
      LIST_THUMBNAILS.map do |name, size|
        save_to = "#{File.dirname(first_page)}/#{name}"
        thumbnail(first_page, save_to, **size)
        save_to
      end
    end

    # 一覧用のサムネイル。既定は 4:3 (320x240)。16:9 用は width: 480, height: 270 で作る
    def thumbnail(src, dest, width: 320, height: 240)
      thumb = Magick::Image.from_blob(File.read(src)).shift
      thumb_out = if thumb.columns < width || thumb.rows < height
                    cover_white(thumb, width, height)
                  else
                    shrink_to_fill(thumb, width, height)
                  end
      thumb_out.write(dest)
    end

    # Create Middle Sized Image
    def shrink(src, dest)
      width = 1200

      thumb = Magick::Image.from_blob(File.read(src)).shift
      thumb_out = if thumb.columns > width
                    shrink_to_fill(thumb, width, thumb.rows * width / thumb.columns)
                  else
                    shrink_to_fill(thumb, thumb.columns, thumb.rows)
                  end
      thumb_out.write(dest)
    end

    private

      def shrink_to_fill(image, width, height)
        image.resize_to_fill!(width, height)
        image
      end

      def cover_white(image, width, height)
        new_width = image.columns < width ? image.columns : width
        new_height = image.rows < height ? image.rows : height

        image.resize_to_fit!(new_width, new_height)
        image_out = Magick::Image.new(width, height)
        image_out.background_color = '#ffffff'
        image_out.composite!(image, Magick::CenterGravity, Magick::OverCompositeOp)
        image_out
      end
  end
end
