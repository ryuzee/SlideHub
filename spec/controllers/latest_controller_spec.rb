require 'rails_helper'

RSpec.describe LatestController, type: :controller do
  describe 'GET #index' do
    it 'shows published slides, newest first' do
      older = create(:slide, created_at: 2.days.ago)
      newer = create(:slide, created_at: 1.day.ago)
      create(:slide, private: true)
      get :index
      expect(response.status).to eq(200)
      expect(response).to render_template :index
      expect(assigns(:slides).to_a).to eq([newer, older])
    end
  end
end
