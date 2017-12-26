# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = Rails.application.config.slidehub.root_url

SitemapGenerator::Sitemap.create do
  Slide.published.latest.each do |s|
    add slide_path(s), lastmod: s.created_at
  end
end
