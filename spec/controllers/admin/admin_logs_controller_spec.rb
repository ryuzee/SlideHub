require 'rails_helper'

RSpec.describe Admin::LogsController, type: :controller do
  describe 'Logs' do
    let(:admin_user) { create(:admin_user) }
    before do
      login_by_admin_user admin_user
    end

    describe 'GET /admin/logs/index' do
      it 'works!' do
        get 'index'
        expect(response.status).to eq(200)
      end
    end

    describe 'GET /admin/logs/show' do
      it 'works!' do
        get :show, params: { path: Rails.root.join('log', 'test.log') }
        expect(response.status).to eq(200)
      end

      it 'redirect to index' do
        get :show, params: { path: '/etc/password' }
        expect(response.status).to eq(302)
      end
    end
  end
end
