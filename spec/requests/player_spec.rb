require 'rails_helper'

describe 'Player' do
  describe 'GET /player/1' do
    it 'returns the script that shows every page' do
      slide = create(:slide, num_of_pages: 2)
      get "/player/#{slide.id}"
      expect(response.status).to eq(200)
      expect(response.body).to include('getElementById')
      expect(response.body).to include("#{slide.object_key}/slide-2.jpg")
    end
  end

  describe 'GET /player/v2/1' do
    it 'returns the version 2 script that shows every page' do
      slide = create(:slide, num_of_pages: 2)
      get "/player/v2/#{slide.id}"
      expect(response.status).to eq(200)
      expect(response.body).to include('getElementById')
      expect(response.body).to include("#{slide.object_key}/slide-2.jpg")
    end
  end
end
