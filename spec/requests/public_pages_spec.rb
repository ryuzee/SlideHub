require 'rails_helper'

# 作り直した公開ページの見た目の決まりごと（テーマ、カスタムコンテンツの置き場所、カードなど）
describe 'Public pages' do
  def page_html
    Nokogiri::HTML(response.body)
  end

  describe 'layout' do
    describe 'light and dark' do
      it 'uses the dark mode only for the dark theme' do
        { 'dark' => 'dark', 'default' => 'light', 'white' => 'light', 'gray' => 'light' }.each do |theme, mode|
          ApplicationSetting['site.theme'] = theme
          get '/'
          expect(page_html.at('html')['data-bs-theme']).to eq(mode)
          expect(page_html.at('body')['class']).to include("theme-#{theme}")
        end
      end

      it 'falls back to the default theme for an unknown value' do
        ApplicationSetting['site.theme'] = 'neon'
        get '/'
        expect(page_html.at('body')['class']).to include('theme-default')
        expect(page_html.at('html')['data-bs-theme']).to eq('light')
      end
    end

    describe 'header' do
      it 'has the site search form' do
        get '/latest'
        expect(page_html.at('form.site-search input[name="q[name_cont]"]')).not_to be_nil
      end
    end

    describe 'custom content at the center top' do
      it 'is not shown when it is empty' do
        ApplicationSetting['custom_content.center_top'] = ''
        get '/latest'
        expect(page_html.at('.site-custom-top')).to be_nil
      end

      it 'is shown at the very top, with the background of the band below it' do
        ApplicationSetting['custom_content.center_top'] = '<p class="notice-banner">Notice</p>'
        create(:featured_slide)

        get '/'
        top = page_html.at('.site-custom-top')
        expect(top.at('.notice-banner')).not_to be_nil
        expect(top['class']).to include('site-custom-top-stage', 'sh-stage')

        get "/users/#{create(:slide).user_id}"
        expect(page_html.at('.site-custom-top')['class']).to include('site-custom-top-paper')

        get '/latest'
        expect(page_html.at('.site-custom-top')['class'].split).to eq(['site-custom-top'])
      end
    end

    describe 'footer' do
      it 'shows the site name as text and the footer setting as HTML' do
        ApplicationSetting['site.name'] = '<b>My</b> Hub'
        ApplicationSetting['site.footer'] = '<a href="/pages/about">About us</a>'
        get '/latest'
        footer = page_html.at('footer.custom-footer')
        expect(footer.at('.site-footer-brand .fw-bold').text).to eq('<b>My</b> Hub')
        expect(footer.at('.site-footer-note a[href="/pages/about"]').text).to eq('About us')
      end
    end
  end

  describe 'slide cards' do
    it 'shows the title, a shortened description, the page count and a paper stack by page count' do
      create(:slide, name: 'One pager', num_of_pages: 1, description: 'Short')
      create(:slide, name: 'Long deck', num_of_pages: 40, description: 'word ' * 60)
      get '/latest'
      cards = page_html.css('article.slidecard').to_h { |card| [card.at('.slidecard-title a').text, card] }

      expect(cards['One pager']['data-deck']).to eq('0')
      expect(cards['Long deck']['data-deck']).to eq('2')
      expect(cards['Long deck'].at('.slidecard-pages').text).to include('40')
      description = cards['Long deck'].at('.slidecard-description').text
      expect(description.length).to be <= 140
      expect(description).to end_with('...')
    end

    it 'marks a private slide in my own list' do
      user = create(:default_user)
      create(:slide, user: user, private: true)
      sign_in user
      get '/users'
      expect(page_html.at('article.slidecard .slidecard-author .badge').text).to eq(I18n.t(:private_slide))
    end
  end

  describe 'top page' do
    it 'shows the first featured slide large, with its title and a button to the slide' do
      featured = create(:featured_slide, slide: create(:slide, name: 'Featured Talk'))
      get '/'
      hero = page_html.at('#featured')
      expect(hero.at('.sh-hero-title').text).to include('Featured Talk')
      expect(hero.at(%(a.btn[href="/slides/#{featured.slide_id}"]))).not_to be_nil
      expect(hero.at('.sh-filmstrip')).to be_nil
    end

    it 'shows no hero when nothing is featured' do
      get '/'
      expect(page_html.at('#featured')).to be_nil
    end
  end

  describe 'category lists' do
    let!(:with_slide) { create(:slide).category }
    let!(:empty) { Category.create!(name_en: 'Empty', name_ja: 'Empty_ja') }
    let!(:only_private) do
      Category.create!(name_en: 'Private', name_ja: 'Private_ja').tap { |category| create(:slide, category: category, private: true) }
    end

    # 押しても 0 件になるカテゴリは出さない
    def category_links(selector)
      page_html.css("#{selector} a").map { |link| link['href'] }
    end

    it 'shows only the categories with a published slide on the top page and in the header' do
      get '/'
      expect(category_links('#categories')).to eq(["/categories/#{with_slide.id}"])
      expect(category_links('.navbar .dropdown-menu')).to eq(["/categories/#{with_slide.id}"])
    end

    it 'shows only the categories with a published slide on a category page' do
      get "/categories/#{with_slide.id}"
      expect(category_links('.sh-chips')).to eq(["/categories/#{with_slide.id}"])
    end
  end

  describe 'slide page' do
    let(:slide) { create(:slide, name: 'Sushi Talk', tag_list: 'Sushi,Toro', num_of_pages: 2) }

    it 'shows the custom content for the right top right after the tags, not in the side column' do
      ApplicationSetting['custom_content.right_top'] = '<div class="book-ad">Book</div>'
      get "/slides/#{slide.id}"
      main = page_html.at('.sh-slide-body .col-lg-8')
      after_tags = main.at('.sh-tags').xpath('following-sibling::*').map { |node| node['class'] }
      expect(after_tags).to include('sh-custom-right-top')
      expect(main.at('.sh-custom-right-top .book-ad')).not_to be_nil
      expect(page_html.at('.sh-slide-body aside .book-ad')).to be_nil
    end

    it 'shows at most six related slides in the side column' do
      create_list(:slide, 8, category: slide.category)
      get "/slides/#{slide.id}"
      expect(page_html.css('.sh-slide-body aside .sh-related > *').size).to eq(6)
    end

    it 'shows the text and the comments in full width below the two columns' do
      get "/slides/#{slide.id}"
      body = page_html.at('.sh-slide-body')
      sections = body.xpath('./section').map { |node| node['aria-labelledby'] }
      expect(sections).to eq(%w[transcript-heading comments-heading])
      expect(body.at('.row section')).to be_nil
    end
  end

  describe 'profile page' do
    it 'shows the biography and the popular tags of the user' do
      user = create(:default_user, biography: 'Agile coach')
      create(:slide, user: user, tag_list: 'Scrum')
      get "/users/#{user.id}"
      expect(page_html.at('.sh-profile-bio').text).to eq('Agile coach')
      expect(page_html.css('.sh-profile-tags a').map(&:text)).to include('Scrum')
    end
  end

  describe 'sign-in page' do
    it 'shows the external services as buttons that post, above the e-mail form' do
      get '/users/sign_in'
      providers = page_html.css('.sh-auth-providers form.sh-auth-provider')
      expect(providers.map { |form| form['action'] }).to include('/users/auth/twitter', '/users/auth/facebook')
      expect(providers.map { |form| form['method'] }.uniq).to eq(['post'])
      expect(page_html.at('.sh-auth-divider')).not_to be_nil
      expect(page_html.at('form.sh-auth-form input[name="user[email]"]')).not_to be_nil
    end
  end
end
