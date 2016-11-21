require 'rails_helper'

describe 'Search' do
  describe 'GET /search' do
    it 'works!' do
      get '/search'
      expect(response.status).to eq(200)
    end
  end
end
