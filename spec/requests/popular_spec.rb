require 'rails_helper'

describe 'PopularSlides' do
  describe 'GET /index' do
    it 'works!' do
      get '/popular'
      expect(response.status).to eq(200)
      get '/slides/popular'
      expect(response.status).to eq(200)
    end
  end

  describe 'GET /index.rss' do
    it 'works!' do
      get '/popular.rss'
      expect(response.status).to eq(200)
      get '/slides/popular.rss'
      expect(response.status).to eq(200)
    end
  end
end
