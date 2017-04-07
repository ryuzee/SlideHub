require 'rails_helper'

RSpec.describe Admin::SiteSettingsController, type: :controller do
  describe 'SiteSettings' do
    let(:admin_user) { create(:admin_user) }
    before do
      login_by_admin_user admin_user
    end

    describe 'GET /admin/site_settings' do
      it 'works!' do
        get 'index'
        expect(response.status).to eq(200)
      end
    end

    describe 'POST /admin/site_settings/update' do
      it 'works!' do
        data = [{ 'var' => 'site.Neta1', 'value' => 'Toro' }, { 'var' => 'site.Neta2', 'value' => 'Unit' }]
        post :update, params: { settings: data }
        expect(response.status).to eq(302)
        expect(response).to redirect_to '/admin/site_settings/'
        settings = CustomSetting.unscoped.where("var like 'site.Neta%'")
        expect(settings.length).to eq(2)
      end
    end
  end
end
