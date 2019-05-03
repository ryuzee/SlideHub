require 'rails_helper'

RSpec.describe CategoriesController, type: :controller do
  describe 'GET #category' do
    it 'render category' do
      slide = create(:slide)
      get :show, params: { id: slide.category_id }
      expect(response.status).to eq(200)
      expect(response).to render_template :show
    end
  end
end
