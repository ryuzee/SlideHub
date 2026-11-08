require 'rails_helper'

describe 'Slides' do
  describe 'GET /' do
    it 'shows the top page with the latest slides' do
      create(:slide, name: 'Sushi Talk')
      get '/'
      expect(response.status).to eq(200)
      expect(response.body).to include('Sushi Talk')
    end

    it 'links the site name to /' do
      get '/'
      expect(Nokogiri::HTML(response.body).at('a.navbar-brand')['href']).to eq('/')
    end
  end

  describe 'the old URLs of the top page' do
    it 'moves /slides and /slides/index to /' do
      get '/slides'
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to('/')
      get '/slides/index'
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to('/')
    end

    it 'keeps the page number' do
      get '/slides?page=2'
      expect(response).to redirect_to('/?page=2')
    end
  end

  describe 'any page' do
    it 'does not delete sessions while showing a page' do
      expect(ActiveRecord::SessionStore::Session).not_to receive(:where)
      get '/'
      expect(response.status).to eq(200)
    end
  end

  describe 'GET /slides/1' do
    it 'shows the slide with its first page' do
      slide = create(:slide, name: 'Sushi Talk', num_of_pages: 2)
      get "/slides/#{slide.id}"
      expect(response.status).to eq(200)
      expect(response.body).to include('Sushi Talk')
      expect(response.body).to include("#{slide.object_key}/slide-1.jpg")
    end
  end
end
