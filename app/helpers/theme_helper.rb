module ThemeHelper
  # public/themes/<theme>/<file> を読み込む link タグ。
  # テーマ CSS は public 配下の静的ファイルでダイジェストが付かないため、
  # 更新日時をクエリに付けてブラウザのキャッシュを更新させる。
  def theme_stylesheet_link_tag(theme, file)
    path = Rails.public_path.join('themes', theme, file)
    version = File.exist?(path) ? File.mtime(path).to_i : 0
    stylesheet_link_tag("/themes/#{theme}/#{file}?#{version}")
  end
end
