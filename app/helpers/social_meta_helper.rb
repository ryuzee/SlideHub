# SNS で共有したときのカード（OGP と Twitter カード）。
# スライドのページは slides/_meta_tags ですべて決めるので、ここではそれ以外のページに足りない値を補う。
# レイアウトから、ページの描画が済んだあと（display_meta_tags の前）に呼ぶ
module SocialMetaHelper
  def default_social_meta_tags(title)
    og = meta_tags[:og] || {}
    fallback = {
      title: title.presence || ApplicationSetting['site.name'],
      description: meta_tags[:description],
      url: meta_tags[:canonical],
      image: ApplicationSetting['site.og_image'],
    }
    # ページで決めた値を優先し、空いているところだけ補う
    filled = fallback.compact_blank.merge(og.to_h.symbolize_keys.compact_blank)
    set_meta_tags og: filled
    # 補った画像を使うときは、大きな画像のカードにする（スライドのページは自分で決めている）
    set_meta_tags twitter: { card: 'summary_large_image' } if filled[:image].present? && og[:image].blank?
  end
end
