# 公開ページで繰り返し使う表示の部品
module PublicPageHelper
  # 一覧やカードに出す短い日付（例: 2026年4月10日）
  def compact_date(time)
    return '' if time.nil?

    tag.time(l(time.to_date, format: t(:date_format_compact)), datetime: time.iso8601)
  end

  # ユーザーのアバター。登録が無ければ既定の画像を出す
  def user_avatar_tag(user, size: 40, **options)
    source = user&.avatar&.attached? ? url_for(user.avatar) : 'avatar/medium/missing.png'
    classes = ['sh-avatar', options.delete(:class)].compact.join(' ')
    image_tag(source, size: "#{size}x#{size}", alt: '', class: classes, **options)
  end

  # スライドのページ画像の URL。from は 0 始まりの位置
  def slide_page_image_urls(slide, from: 0, count: 4)
    list = slide.pages.list
    return [] unless list.is_a?(Array)

    list.drop(from).first(count).map { |key| "#{CloudConfig.provider.resource_endpoint}/#{key}" }
  end
end
