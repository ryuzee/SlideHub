require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  describe 'Users' do
    let(:user_admin) { create(:user_admin) }
    before do
      login_by_admin_user user_admin
    end

    describe 'GET /admin/users/' do
      it 'works!' do
        get 'index'
        expect(response.status).to eq(200)
      end
    end
  end
end
