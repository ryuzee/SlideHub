require 'rails_helper'

RSpec.describe PopularController, type: :controller do
  describe 'GET #index' do
    it 'shows published slides, most viewed first' do
      less = create(:slide, total_view: 1)
      more = create(:slide, total_view: 100)
      create(:slide, private: true, total_view: 1000)
      get :index
      expect(response.status).to eq(200)
      expect(response).to render_template :index
      expect(assigns(:slides).to_a).to eq([more, less])
    end
  end
end
