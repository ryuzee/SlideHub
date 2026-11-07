require 'rails_helper'

RSpec.describe StatisticsController, type: :controller do
  describe 'When logged in' do
    let(:default_user) { create(:default_user) }
    before do
      login_by_user default_user
    end

    describe 'GET /statistics/index' do
      it 'shows the statistics of my slides only' do
        mine = create(:slide, user: default_user)
        create(:slide, user: create(:another_user))
        get 'index'
        expect(response.status).to eq(200)
        expect(response).to render_template :index
        expect(assigns(:slides).to_a).to eq([mine])
      end
    end
  end

  describe 'No Login' do
    describe 'GET /statistics/index' do
      it 'redirects to the sign-in page' do
        get 'index'
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
