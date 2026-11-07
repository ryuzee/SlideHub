require 'rails_helper'

RSpec.describe SearchController, type: :controller do
  describe 'GET #index' do
    it 'finds published slides whose name matches' do
      hit = create(:slide, name: 'Sushi Talk')
      create(:slide, name: 'Ramen Talk')
      create(:slide, name: 'Secret Sushi', private: true)
      get :index, params: { q: { name_cont: 'Sushi' } }
      expect(response.status).to eq(200)
      expect(response).to render_template :index
      expect(assigns(:slides).to_a).to eq([hit])
    end
  end
end
