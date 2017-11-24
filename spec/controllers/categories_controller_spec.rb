require 'rails_helper'

RSpec.describe CategoriesController, type: :controller do
  describe 'GET #category' do
    it 'render category' do
      create(:slide)
      get :show, params: { id: '1' }
      expect(response.status).to eq(200)
      expect(response).to render_template :show
    end
  end
end
