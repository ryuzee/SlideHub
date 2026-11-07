require 'rails_helper'

RSpec.describe SlidePageCountController, type: :controller do
  describe 'GET #show' do
    it 'returns the number of pages of the slide' do
      slide = create(:slide, num_of_pages: 3)
      get :show, params: { id: slide.id }
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)['page_count']).to eq(3)
    end

    it 'returns 0 for a slide that does not exist' do
      get :show, params: { id: 65535 }
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)['page_count']).to eq(0)
    end

    it 'returns 0 for a slide that has not been converted yet' do
      slide = create(:slide, convert_status: :unconverted, num_of_pages: 0)
      get :show, params: { id: slide.id }
      expect(JSON.parse(response.body)['page_count']).to eq(0)
    end
  end
end
