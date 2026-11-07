require 'rails_helper'

RSpec.describe Admin::DashboardsController, type: :controller do
  describe 'GET /admin/dashboard' do
    render_views
    context 'with admin permission' do
      let(:admin_user) { create(:admin_user) }
      before do
        login_by_admin_user admin_user
        # 本物のキューに問い合わせない（SQS クライアントが作られると AWS エンジンのテストのダミーが使われなくなる）
        allow(CloudConfig.provider).to receive(:queue_length).and_return(3)
      end

      it 'shows the monthly chart, the queue length and a link to failed slides' do
        create(:slide, convert_status: Slide.convert_statuses[:convert_error])
        get 'show'
        expect(response.body).to include(I18n.t(:monthly_uploads))
        expect(response.body).to include(I18n.t(:queue_messages, count: 3))
        expect(response.body).to include(CGI.escapeHTML(admin_slides_path(q: { convert_status_eq: -1 })))
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
