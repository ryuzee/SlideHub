require 'rails_helper'

RSpec.describe Admin::CustomContentsController, type: :controller do
  describe 'CustomContents' do
    render_views
    let(:admin_user) { create(:admin_user) }
    before do
      login_by_admin_user admin_user
    end

    describe 'GET /admin/custom_contents/' do
      it 'shows a tab and an editor with the current value for each setting' do
        ApplicationSetting['custom_content.center_top'] = '<p>Hello banner</p>'
        get 'index'
        expect(response.status).to eq(200)
        %w[center_top center_bottom right_top header_menus css].each do |name|
          expect(response.body).to include(%(id="tab-#{name}"))
        end
        expect(response.body).to include('&lt;p&gt;Hello banner&lt;/p&gt;')
      end
    end

    describe 'POST /admin/custom_contents/update' do
      it 'saves every setting sent from the tabs' do
        data = [{ 'var' => 'custom_content.Neta1', 'value' => 'Toro' }, { 'var' => 'custom_content.Neta2', 'value' => 'Unit' }]
        post :update, params: { settings: data }
        expect(response.status).to eq(302)
        expect(response).to redirect_to '/admin/custom_contents/'
        settings = ApplicationSetting.unscoped.where("var like 'custom_content.Neta%'")
        expect(settings.length).to eq(2)
        expect(flash[:notice]).to eq(I18n.t(:custom_contents_were_saved))
      end
    end
  end
end
