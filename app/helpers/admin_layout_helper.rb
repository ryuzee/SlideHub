module AdminLayoutHelper
  # 管理画面の各ページの見出し（タイトルとパンくず）。タイトルはブロックで渡す。
  #   <%= admin_page_header(section: link_to(t(:logs), admin_logs_index_path)) do %>タイトル<% end %>
  # section を省略するとパンくずを出さない（ダッシュボード）
  def admin_page_header(section: nil, &)
    render 'admin/shared/page_header', title: capture(&), section: section
  end

  SLIDE_STATUS_BADGE_CLASSES = {
    'converted' => 'text-bg-success',
    'unconverted' => 'text-bg-secondary',
    'convert_error' => 'text-bg-danger',
  }.freeze

  # スライドの変換状態のバッジ（変換済み・未変換・失敗を色分けする）
  def slide_status_badge(slide)
    tag.span(slide.convert_status_i18n, class: ['badge', SLIDE_STATUS_BADGE_CLASSES.fetch(slide.convert_status, 'text-bg-secondary')])
  end

  # 検索条件のうち、常に表示している欄（keys）以外が指定されているか。詳細検索を開いた状態で表示するのに使う
  def advanced_search_used?(keys)
    query = params[:q]
    return false if query.blank?

    query.to_unsafe_h.except(*keys).values.any?(&:present?)
  end
end
