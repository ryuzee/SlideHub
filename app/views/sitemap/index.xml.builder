xml.instruct!
xml.urlset xmlns: 'http://www.sitemaps.org/schemas/sitemap/0.9' do

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