require 'rails_helper'

describe 'Slides' do
  describe 'GET /slides' do
    it 'works!' do
      get '/slides'
      expect(response.status).to eq(200)
    end
  end

  describe 'GET /slides/popular' do
    it 'works!' do
      get '/slides/popular'
      expect(response.status).to eq(200)
    end
  end

  describe 'GET /slides/latest' do
    it 'works!' do
      get '/slides/latest'
      expect(response.status).to eq(200)
    end
  end

  describe 'GET /slides/search' do
    it 'works!' do
      get '/slides/search'
      expect(response.status).to eq(200)
    end
  end

  describe 'GET /slides/1' do
    it 'works!' do
      create_list(:slide, 2)
      allow_any_instance_of(Slide).to receive(:page_list).and_return(["/aaa/1.jpg", "/aaa/2.jpg"])
      allow_any_instance_of(Slide).to receive(:transcript).and_return([])
      get '/slides/1'
      expect(response.status).to eq(200)
    end
  end

  # rss
  describe 'GET /slides/popular.rss' do
    it 'works!' do
      get '/slides/popular.rss'
      expect(response.status).to eq(200)
    end
  end

  describe 'GET /slides/latest.rss' do
    it 'works!' do
      get '/slides/latest.rss'
      expect(response.status).to eq(200)
    end
  end
end
