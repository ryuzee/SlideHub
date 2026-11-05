module ThumbnailImageHelper
  # 一覧用のサムネイル画像。枠を 4:3 に固定し（.slide-thumbnail）、
  # 画像が読み込めないときは JS (image_fallback.js) で no_image.svg に差し替える。
  def slide_thumbnail_tag(slide, **options)
    classes = ['slide-thumbnail', options.delete(:class)].compact.join(' ')
    image_tag(thumbnail_image_url(slide),
              alt: strip_tags(slide.name), loading: 'lazy', class: classes,
              data: { fallback_src: asset_url('no_image.svg') }, **options)
  end

  def thumbnail_image_url(slide)
    if slide.convert_error?
      asset_path('failed_to_convert_small.jpg')
    elsif slide.converted? == false
      asset_path('converting_small.jpg')
    else
      slide.thumbnail.url
    end
  end
end
