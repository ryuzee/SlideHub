require 'rails_helper'

describe 'SEO' do
  def json_ld_blocks(body)
    Nokogiri::HTML(body).css('script[type="application/ld+json"]').map { |s| JSON.parse(s.text) }
  end

  # 一覧は 1 ページ 20 件で、スライドのないページ番号は 404 になる。2 ページ目を開けるだけ作る
  def fill_two_pages(**attributes)
    create_list(:slide, 21, **attributes)
  end

  describe 'GET /slides/:id' do
    let(:slide) { create(:slide, name: 'My </script> Slide', description: "line1\nline2", num_of_pages: 2) }

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
      expect(img['src']).to end_with("#{slide.object_key}/slide-1.jpg")
      expect(img['alt']).to eq('My  Slide')
    end

    it 'marks private slides as noindex' do
      slide.update!(private: true)
      get "/slides/#{slide.id}"
      expect(Nokogiri::HTML(response.body).at('meta[name="robots"]')['content']).to include('noindex')
    end
  end

  describe 'canonical URLs of the other pages' do
    let(:host) { 'http://www.example.com' }

    def canonical_of(path)
      get path
      expect(response.status).to eq(200)
      Nokogiri::HTML(response.body).at('link[rel="canonical"]')&.[]('href')
    end

    it 'points the top and list pages to their main URLs' do
      expect(canonical_of('/')).to eq("#{host}/")
      expect(canonical_of('/slides/index')).to eq("#{host}/")
      expect(canonical_of('/latest')).to eq("#{host}/latest")
      expect(canonical_of('/slides/latest')).to eq("#{host}/latest")
      expect(canonical_of('/popular?utm_source=x')).to eq("#{host}/popular")
    end

    it 'keeps the page number from the second page on' do
      fill_two_pages
      expect(canonical_of('/latest?page=1')).to eq("#{host}/latest")
      expect(canonical_of('/latest?page=2')).to eq("#{host}/latest?page=2")
    end

    it 'points a category to its URL' do
      category = create(:default_category)
      fill_two_pages(category: category)
      expect(canonical_of("/categories/#{category.id}?page=2")).to eq("#{host}/categories/#{category.id}?page=2")
    end

    # 同じユーザーのページが /users/:id、/users/view/:id、/:username のどれでも出る
    it 'points every URL of a user to the one with the username' do
      user = create(:default_user)
      expect(canonical_of("/users/#{user.id}")).to eq("#{host}/user01")
      expect(canonical_of("/users/view/#{user.id}")).to eq("#{host}/user01")
      expect(canonical_of('/user01')).to eq("#{host}/user01")
    end

    it 'points a page to its URL' do
      create(:default_page, path: 'about', title: 'About this site')
      expect(canonical_of('/pages/about')).to eq("#{host}/pages/about")
    end
  end

  describe 'descriptions of the other pages' do
    def description_of(path, headers: {})
      get path, headers: headers
      expect(response.status).to eq(200)
      Nokogiri::HTML(response.body).at('meta[name="description"]')&.[]('content')
    end

    it 'uses the site description on the top page, or a standard text when it is empty' do
      ApplicationSetting['site.name'] = 'Sushi Slides'
      ApplicationSetting['site.description'] = ''
      expect(description_of('/')).to eq('Sushi Slidesは、スライドを公開して共有できるサイトです。新しいスライドや人気のスライドを、カテゴリやタグから探せます。')
      ApplicationSetting['site.description'] = '<b>Slides</b> about sushi'
      expect(description_of('/')).to eq('Slides about sushi')
    end

    it 'describes the list pages and adds the page number from the second page on' do
      fill_two_pages
      expect(description_of('/latest')).to eq('SlideHubに新しく公開されたスライドの一覧です。')
      expect(description_of('/latest?page=2')).to eq('SlideHubに新しく公開されたスライドの一覧です。（2ページ目）')
      expect(description_of('/popular')).to eq('SlideHubでよく見られているスライドの一覧です。')
    end

    it 'tells the name and the number of slides of a category' do
      slide = create(:slide)
      create(:slide, category: slide.category)
      expect(description_of("/categories/#{slide.category_id}")).to eq('SlideHubの「Category1_ja」カテゴリのスライド（2件）の一覧です。')
    end

    it 'describes a user with the biography' do
      user = create(:default_user, biography: 'Sushi lover')
      create(:slide, user: user)
      expect(description_of('/user01')).to eq('User01さんがSlideHubで公開しているスライド（1件）の一覧です。Sushi lover')
    end

    it 'escapes the marks only once' do
      create(:default_category, name_en: 'Books & "Magazines"')
      category = Category.find_by(name_en: 'Books & "Magazines"')
      get "/categories/#{category.id}", headers: { 'Accept-Language' => 'en' }
      expect(response.body).to include('content="Slides in the &quot;Books &amp; &quot;Magazines&quot;&quot; category')
    end

    it 'cuts a long text of a page' do
      create(:default_page, path: 'about', title: 'About', content: "<p>#{'word ' * 100}</p>")
      text = description_of('/pages/about')
      expect(text.length).to be <= 160
      expect(text).to start_with('word word')
    end
  end

  describe 'share cards of the other pages' do
    def og(path)
      get path
      doc = Nokogiri::HTML(response.body)
      %w[title description url image].to_h { |key| [key, doc.at(%(meta[property="og:#{key}"]))&.[]('content')] }.
        merge('card' => doc.at('meta[name="twitter:card"]')&.[]('content'))
    end

    it 'fills the title, the description and the URL from the page' do
      fill_two_pages
      expect(og('/latest?page=2')).to include(
        'title' => '最新のスライド',
        'description' => 'SlideHubに新しく公開されたスライドの一覧です。（2ページ目）',
        'url' => 'http://www.example.com/latest?page=2',
        'image' => nil,
        'card' => 'summary',
      )
    end

    it 'uses the site name as the title of the top page' do
      ApplicationSetting['site.name'] = 'Sushi Slides'
      expect(og('/')['title']).to eq('Sushi Slides')
    end

    it 'uses the share image of the site settings with the large card' do
      ApplicationSetting['site.og_image'] = 'https://example.com/ogp.png'
      user = create(:default_user)
      expect(og("/users/#{user.id}")).to include(
        'title' => 'User01さんのスライド',
        'url' => 'http://www.example.com/user01',
        'image' => 'https://example.com/ogp.png',
        'card' => 'summary_large_image',
      )
    end

    it 'keeps the image of the slide on a slide page' do
      ApplicationSetting['site.og_image'] = 'https://example.com/ogp.png'
      slide = create(:slide)
      expect(og("/slides/#{slide.id}")['image']).not_to eq('https://example.com/ogp.png')
    end
  end

  describe 'GET / (title and heading)' do
    def top_page
      get '/'
      Nokogiri::HTML(response.body)
    end

    it 'puts the site name first and the tagline after it' do
      ApplicationSetting['site.name'] = 'Sushi Slides'
      ApplicationSetting['site.tagline'] = 'Talks on sushi'
      expect(top_page.at('title').text).to eq('Sushi Slides | Talks on sushi')
    end

    it 'uses only the site name when the tagline is empty' do
      ApplicationSetting['site.name'] = 'Sushi Slides'
      ApplicationSetting['site.tagline'] = ''
      expect(top_page.at('title').text).to eq('Sushi Slides')
    end

    it 'keeps the order of the other pages' do
      ApplicationSetting['site.name'] = 'Sushi Slides'
      get '/latest'
      expect(Nokogiri::HTML(response.body).at('title').text).to eq('最新のスライド | Sushi Slides')
    end

    it 'has the site name as the only H1, even with a featured slide' do
      ApplicationSetting['site.name'] = 'Sushi Slides'
      create(:featured_slide, slide: create(:slide, name: 'Featured Talk'))
      doc = top_page
      expect(doc.css('h1').map(&:text)).to eq(['Sushi Slides'])
      expect(doc.at('h2.sh-hero-title').text).to include('Featured Talk')
    end
  end

  describe 'structured data of the other pages' do
    def types_and_data(path)
      get path
      json_ld_blocks(response.body).index_by { |data| data['@type'] }
    end

    it 'describes the site on the top page' do
      ApplicationSetting['site.name'] = 'Sushi Slides'
      ApplicationSetting['site.description'] = 'Slides about sushi'
      site = types_and_data('/')['WebSite']
      expect(site).to include('name' => 'Sushi Slides', 'url' => 'http://www.example.com/', 'description' => 'Slides about sushi')
    end

    it 'describes a user as a profile page' do
      user = create(:default_user, biography: '<b>Sushi</b> lover', twitter_account: 'sushi_chef')
      profile = types_and_data("/users/#{user.id}")['ProfilePage']
      expect(profile['url']).to eq('http://www.example.com/user01')
      expect(profile['mainEntity']).to include(
        '@type' => 'Person', 'name' => 'User01', 'alternateName' => 'user01',
        'description' => 'Sushi lover', 'sameAs' => ['https://x.com/sushi_chef']
      )
    end

    it 'describes a category as a collection with the breadcrumb' do
      category = create(:default_category)
      fill_two_pages(category: category)
      data = types_and_data("/categories/#{category.id}?page=2")
      expect(data['CollectionPage']).to include('name' => 'Category1_ja', 'url' => "http://www.example.com/categories/#{category.id}?page=2")
      expect(data['BreadcrumbList']['itemListElement'].map { |item| item['name'] }).to eq(%w[SlideHub Category1_ja])
    end

    it 'describes the latest and popular lists as collections' do
      expect(types_and_data('/latest')['CollectionPage']['description']).to eq('SlideHubに新しく公開されたスライドの一覧です。')
      expect(types_and_data('/popular')['CollectionPage']['url']).to eq('http://www.example.com/popular')
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

    def sitemap_locs
      get '/sitemap.xml'
      Nokogiri::XML(response.body).remove_namespaces!.xpath('//url/loc').map(&:text)
    end

    it 'lists only the categories that have a published slide' do
      published = create(:slide)
      empty = Category.create!(name_en: 'Empty', name_ja: 'Empty_ja')
      only_private = Category.create!(name_en: 'Private', name_ja: 'Private_ja')
      create(:slide, category: only_private, private: true)
      expect(sitemap_locs).to include("http://www.example.com/categories/#{published.category_id}")
      expect(sitemap_locs).not_to include("http://www.example.com/categories/#{empty.id}",
                                          "http://www.example.com/categories/#{only_private.id}")
    end

    it 'lists the pages' do
      create(:default_page, path: 'about', title: 'About this site')
      expect(sitemap_locs).to include('http://www.example.com/pages/about')
    end
  end

  describe 'GET /categories/:id' do
    def robots_of(category)
      get "/categories/#{category.id}"
      Nokogiri::HTML(response.body).at('meta[name="robots"]')&.[]('content')
    end

    it 'is noindex when the category has no published slide' do
      empty = Category.create!(name_en: 'Empty', name_ja: 'Empty_ja')
      robots = robots_of(empty)
      expect(response.status).to eq(200)
      expect(robots).to include('noindex')
      expect(robots).not_to include('nofollow')
    end

    it 'can be indexed when the category has a slide' do
      slide = create(:slide)
      expect(robots_of(slide.category)).to be_nil
    end
  end
end
