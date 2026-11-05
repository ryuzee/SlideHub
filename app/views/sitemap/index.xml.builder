xml.instruct!
xml.urlset xmlns: 'http://www.sitemaps.org/schemas/sitemap/0.9' do
  # トップ・一覧ページ
  [root_url, latest_index_url, popular_index_url].each do |url|
    xml.url do
      xml.loc url
      xml.changefreq 'daily'
      xml.priority '0.8'
    end
  end

  # カテゴリ
  @categories.each do |category|
    xml.url do
      xml.loc category_url(category.id)
      xml.changefreq 'weekly'
      xml.priority '0.6'
    end
  end

  # 公開スライドを持つユーザー
  @users.each do |user|
    xml.url do
      xml.loc user_by_username_url(username: user.username)
      xml.changefreq 'weekly'
      xml.priority '0.5'
    end
  end

  # 個別のスライドページ
  @slides.each do |slide|
    xml.url do
      xml.loc slide_url(slide)
      xml.changefreq 'monthly'
      xml.priority '0.7'
      lastmod = slide.updated_at || slide.created_at || Time.new(2015, 1, 1)
      xml.lastmod lastmod.iso8601
    end
  end
end
