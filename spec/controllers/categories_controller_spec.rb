require 'rails_helper'

RSpec.describe CategoriesController, type: :controller do
  let(:first_user) { create(:first_user) }

  describe 'GET #category' do
    it 'render category' do
      create(:slide)
      create(:first_category)
      get :show, params: { id: '1' }
      expect(response.status).to eq(200)
      expect(response).to render_template :show
    end
  end
end
