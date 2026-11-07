require 'rails_helper'

RSpec.describe CategoriesController, type: :controller do
  describe 'GET #category' do
    it 'shows the published slides in the category' do
      slide = create(:slide)
      create(:slide, category: create(:default_category, name_en: 'Other', name_ja: 'その他'))
      create(:slide, private: true)
      get :show, params: { id: slide.category_id }
      expect(response.status).to eq(200)
      expect(response).to render_template :show
      expect(assigns(:slides)).to eq([slide])
    end
  end
end
