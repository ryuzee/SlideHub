require 'rails_helper'

RSpec.describe Admin::LogsController, type: :controller do
  describe 'Logs' do
    render_views
    let(:admin_user) { create(:admin_user) }
    before do
      login_by_admin_user admin_user
    end

    describe 'GET /admin/logs/index' do
      it 'lists the log files' do
        get 'index'
        expect(response.status).to eq(200)
        expect(response.body).to include('test.log')
      end
    end

    describe 'GET /admin/logs/show' do
      it 'shows the last lines of a log file' do
        get :show, params: { path: Rails.root.join('log', 'test.log') }
        expect(response.status).to eq(200)
        expect(assigns(:result)).not_to be_empty
        expect(assigns(:result).size).to be <= 300
      end

      it 'does not show a file that is not one of the logs' do
        get :show, params: { path: '/etc/passwd' }
        expect(response).to redirect_to admin_logs_index_path
        expect(assigns(:result)).to be_empty
      end
    end

    describe 'GET /admin/logs/download' do
      it 'sends a log file as a download' do
        get :download, params: { path: Rails.root.join('log', 'test.log') }
        expect(response.status).to eq(200)
        expect(response.headers['Content-Disposition']).to match(/attachment; filename="test\.log"/)
      end

      it 'does not send a file that is not one of the logs' do
        get :download, params: { path: '/etc/passwd' }
        expect(response.status).to eq(302)
        expect(response.headers['Content-Disposition']).to be_nil
      end
    end
  end
end
