# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = ENV['OSS_ROOT_URL']

SitemapGenerator::Sitemap.create do
  Slide.published.latest.each do |s|
    add slide_path(s), :lastmod => s.created_at
  end
end
