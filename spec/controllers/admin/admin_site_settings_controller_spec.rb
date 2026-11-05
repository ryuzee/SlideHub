require 'rails_helper'

RSpec.describe Admin::SiteSettingsController, type: :controller do
  describe 'SiteSettings' do
    render_views
    let(:admin_user) { create(:admin_user) }
    before do
      login_by_admin_user admin_user
    end

    describe 'GET /admin/site_settings' do
      it 'works!' do
        get 'index'
        expect(response.status).to eq(200)
      end

      it 'creates rows for settings added later and shows the regeneration button' do
        Setting.where(var: 'site.thumbnail_aspect_ratio').delete_all
        get 'index'
        expect(Setting.where(var: 'site.thumbnail_aspect_ratio').count).to eq(1)
        expect(response.body).to include(I18n.t('site.thumbnail_aspect_ratio'))
        expect(response.body).to include(admin_thumbnail_regeneration_path)
      end
    end

    describe 'POST /admin/site_settings/update' do
      it 'works!' do
        data = [{ 'var' => 'site.Neta1', 'value' => 'Toro' }, { 'var' => 'site.Neta2', 'value' => 'Unit' }]
        post :update, params: { settings: data }
        expect(response.status).to eq(302)
        expect(response).to redirect_to '/admin/site_settings/'
        settings = ApplicationSetting.unscoped.where("var like 'site.Neta%'")
        expect(settings.length).to eq(2)
        expect(flash[:notice]).to eq(I18n.t(:site_settings_were_saved))
      end
    end
  end
end
