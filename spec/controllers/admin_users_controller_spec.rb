require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  describe 'Users' do
    let(:admin_user) { create(:admin_user) }
    before do
      login_by_admin_user admin_user
    end

    describe 'GET /admin/users/' do
      it 'works!' do
        get 'index'
        expect(response.status).to eq(200)
      end
    end
  end
end
