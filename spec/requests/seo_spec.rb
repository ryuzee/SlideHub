require 'rails_helper'

describe 'SEO' do
  def json_ld_blocks(body)
    Nokogiri::HTML(body).css('script[type="application/ld+json"]').map { |s| JSON.parse(s.text) }
  end

  describe 'GET /slides/:id' do
    let(:slide) { create(:slide, name: 'My </script> Slide', description: "line1\nline2") }

    before do
      allow_any_instance_of(SlidePages).to receive(:list).and_return(['abc/slide-1.jpg', 'abc/slide-2.jpg'])
      allow_any_instance_of(Transcript).to receive(:lines).and_return([])
    end

    it 'sets lang, h1, canonical and OGP/Twitter tags' do
      get "/slides/#{slide.id}/2?vertical=1"
      doc = Nokogiri::HTML(response.body)
      expect(doc.at('html')['lang']).to eq('ja')
      expect(doc.at('h1').text).to include('My')
      expect(doc.at('link[rel="canonical"]')['href']).to eq("http://www.example.com/slides/#{slide.id}")
      expect(doc.at('meta[property="og:url"]')['content']).to eq("http://www.example.com/slides/#{slide.id}")
      expect(doc.at('meta[property="og:description"]')['content']).to eq('line1 line2')
      expect(doc.at('meta[property="og:site_name"]')).not_to be_nil
      expect(doc.at('meta[name="twitter:card"]')['content']).to eq('summary_large_image')
      expect(doc.at('meta[name="robots"]')).to be_nil
    end

    it 'embeds escaped JSON-LD for the slide and breadcrumb' do
      get "/slides/#{slide.id}"
      expect(response.body).not_to include('My </script> Slide')
      blocks = json_ld_blocks(response.body)
      doc = blocks.find { |b| b['@type'] == 'PresentationDigitalDocument' }
      expect(doc['name']).to eq('My </script> Slide')
      expect(doc['url']).to eq("http://www.example.com/slides/#{slide.id}")
      expect(doc['author']['@type']).to eq('Person')
      crumbs = blocks.find { |b| b['@type'] == 'BreadcrumbList' }
      expect(crumbs['itemListElement'].map { |i| i['position'] }).to eq([1, 2, 3])
    end

    it 'renders the first slide image for crawlers without JS' do
      get "/slides/#{slide.id}"
      img = Nokogiri::HTML(response.body).at('noscript img')
      expect(img['src']).to end_with('abc/slide-1.jpg')
      expect(img['alt']).to eq('My  Slide')
    end

    it 'marks private slides as noindex' do
      slide.update!(private: true)
      get "/slides/#{slide.id}"
      expect(Nokogiri::HTML(response.body).at('meta[name="robots"]')['content']).to include('noindex')
    end
  end

  describe 'GET /search' do
    it 'is noindex' do
      get '/search'
      expect(Nokogiri::HTML(response.body).at('meta[name="robots"]')['content']).to include('noindex')
    end
  end

  describe 'GET /robots.txt' do
    it 'points to the sitemap of the current host' do
      get '/robots.txt'
      expect(response.status).to eq(200)
      expect(response.media_type).to eq('text/plain')
      expect(response.body).to include('Disallow: /admin/')
      expect(response.body).to include('Sitemap: http://www.example.com/sitemap.xml')
    end
  end

  describe 'GET /sitemap.xml' do
    it 'lists top, category, user and published slide pages only' do
      published = create(:slide)
      hidden = create(:slide, private: true)
      get '/sitemap.xml'
      locs = Nokogiri::XML(response.body).remove_namespaces!.xpath('//url/loc').map(&:text)
      expect(locs).to include('http://www.example.com/')
      expect(locs).to include("http://www.example.com/categories/#{published.category_id}")
      expect(locs).to include('http://www.example.com/user01')
      expect(locs).to include("http://www.example.com/slides/#{published.id}")
      expect(locs).not_to include("http://www.example.com/slides/#{hidden.id}")
    end
  end
end
