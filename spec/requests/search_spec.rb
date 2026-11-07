require 'rails_helper'

describe 'Search' do
  describe 'GET /search' do
    it 'shows the search form' do
      get '/search'
      expect(response.status).to eq(200)
      expect(response.body).to include('name="q[name_cont]"')
    end

    it 'shows the slides that match the words' do
      create(:slide, name: 'Sushi Talk')
      create(:slide, name: 'Ramen Talk')
      get '/search', params: { q: { name_cont: 'Sushi' } }
      expect(response.body).to include('Sushi Talk')
      expect(response.body).not_to include('Ramen Talk')
    end
  end
end
