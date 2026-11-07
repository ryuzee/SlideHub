# 検索結果などに出るページの説明文（meta description）。
# スライドのページは slides/_meta_tags で出すので、ここではそれ以外のページの文を作る
module PageDescriptionHelper
  # 検索結果で切れずに出るくらいの長さにそろえる
  DESCRIPTION_LENGTH = 160

  # 2 ページ目以降は「（2ページ目）」を足して、1 ページ目と同じ説明文にならないようにする
  def page_description(text)
    # strip_tags は記号を &quot; などにするので戻す（出すときに meta-tags がもう一度エスケープする）
    text = CGI.unescapeHTML(strip_tags(text.to_s)).squish
    page = params[:page].to_i
    text += t('page_descriptions.page_number', page: page) if page > 1
    set_meta_tags description: truncate(text, length: DESCRIPTION_LENGTH)
  end

  # サイト設定の「サイトの説明」。空欄なら決まった文を使う
  def site_description
    ApplicationSetting['site.description'].presence || t('page_descriptions.default', site: description_site_name)
  end

  def description_site_name
    ApplicationSetting['site.name'].presence || 'SlideHub'
  end
end
