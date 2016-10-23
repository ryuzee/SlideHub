require 'rails_helper'

RSpec.describe Admin::DashboardsController, type: :controller do
  describe 'Dashboards' do
    let(:user_admin) { create(:user_admin) }
    before do
      login_by_admin_user user_admin
    end

    describe 'GET /admin/dashboards/' do
      it 'works!' do
        get 'index'
        expect(response.status).to eq(200)
      end
    end
  end

  describe 'Managements_without_Login' do
    describe 'GET /admin/dashboards/' do
      it 'redirect to login' do
        get 'index'
        expect(response.status).to eq(302)
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  describe 'Prohibitted to access MC by normal user' do
    describe 'GET /admin/dashboards/' do
      it 'redirect to login' do
        general_user = create(:general_user)
        login_by_user general_user
        get 'index'
        expect(response.status).to eq(302)
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

end
