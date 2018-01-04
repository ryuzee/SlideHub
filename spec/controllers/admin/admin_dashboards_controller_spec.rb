require 'rails_helper'

RSpec.describe Admin::DashboardsController, type: :controller do
  describe 'GET /admin/dashboard' do
    context 'with admin permission' do
      let(:admin_user) { create(:admin_user) }
      before do
        login_by_admin_user admin_user
      end

      it 'works!' do
        get 'show'
        expect(response.status).to eq(200)
      end
    end

    context 'by anonyous user' do
      it 'redirect to login' do
        get 'show'
        expect(response.status).to eq(302)
        expect(response).to redirect_to '/users/sign_in'
      end
    end

    context 'by normal loggedin user' do
      it 'redirect to login' do
        default_user = create(:default_user)
        login_by_user default_user
        get 'show'
        expect(response.status).to eq(302)
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end
end
