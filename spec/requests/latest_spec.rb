require 'rails_helper'

describe 'LatestSlides' do
  describe 'GET /index' do
    it 'works!' do
      get '/latest'
      expect(response.status).to eq(200)
      get '/slides/latest'
      expect(response.status).to eq(200)
    end
  end

  describe 'GET /index.rss' do
    it 'works!' do
      get '/latest.rss'
      expect(response.status).to eq(200)
      get '/slides/latest.rss'
      expect(response.status).to eq(200)
    end
  end
end
