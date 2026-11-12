module ThumbnailImageHelper
  # 一覧用のサムネイル画像。枠の縦横比はサイト設定 site.thumbnail_aspect_ratio（4:3 / 16:9）に従う。
  # 画像が読み込めないときは JS (image_fallback.js) が data-fallback-src の候補を順に試す。
  #   16:9: thumbnail-16x9 → thumbnail（16:9 版をまだ作っていないスライド用）→ no_image.svg
  #   4:3:  thumbnail → no_image.svg
  # （拡張子はスライドの image_format。前に変換したスライドは jpg、今は webp）
  def slide_thumbnail_tag(slide, **options)
    wide = wide_thumbnail? && slide.converted?
    classes = ['slide-thumbnail', ('slide-thumbnail-16x9' if wide_thumbnail?), options.delete(:class)].compact.join(' ')
    fallbacks = [(slide.thumbnail.url if wide), asset_url('no_image.svg')].compact

    image_tag(wide ? slide.thumbnail.url_wide : thumbnail_image_url(slide),
              alt: strip_tags(slide.name), loading: 'lazy', class: classes,
              data: { fallback_src: fallbacks.join(' ') }, **options)
  end

  def wide_thumbnail?
    ApplicationSetting['site.thumbnail_aspect_ratio'] == '16:9'
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
