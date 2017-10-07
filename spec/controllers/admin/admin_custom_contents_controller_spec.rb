require 'rails_helper'

RSpec.describe Admin::CustomContentsController, type: :controller do
  describe 'CustomContents' do
    let(:admin_user) { create(:admin_user) }
    before do
      login_by_admin_user admin_user
    end

    describe 'GET /admin/custom_contents/' do
      it 'works!' do
        get 'index'
        expect(response.status).to eq(200)
      end
    end

    describe 'POST /admin/custom_contents/update' do
      it 'works!' do
        data = [{ 'var' => 'custom_content.Neta1', 'value' => 'Toro' }, { 'var' => 'custom_content.Neta2', 'value' => 'Unit' }]
        post :update, params: { settings: data }
        expect(response.status).to eq(302)
        expect(response).to redirect_to '/admin/custom_contents/'
        settings = CustomSetting.unscoped.where("var like 'custom_content.Neta%'")
        expect(settings.length).to eq(2)
        expect(flash[:notice]).to eq(I18n.t(:custom_contents_were_saved))
      end
    end
  end
end
