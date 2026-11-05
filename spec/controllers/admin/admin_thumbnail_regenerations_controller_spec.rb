require 'rails_helper'

RSpec.describe Admin::ThumbnailRegenerationsController, type: :controller do
  let(:admin_user) { create(:admin_user) }

  before do
    login_by_admin_user admin_user
  end

  describe 'POST /admin/thumbnail_regeneration' do
    it 'queues regeneration and redirects to site settings' do
      allow_any_instance_of(ThumbnailRegenerationService).to receive(:request_all).and_return(3)
      post :create
      expect(response).to redirect_to '/admin/site_settings/'
      expect(flash[:notice]).to eq(I18n.t(:regenerate_thumbnails_requested, count: 3))
    end
  end
end
