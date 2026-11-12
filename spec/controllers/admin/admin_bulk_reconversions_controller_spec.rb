require 'rails_helper'

RSpec.describe Admin::BulkReconversionsController, type: :controller do
  before do
    login_by_admin_user create(:admin_user)
  end

  describe 'POST /admin/bulk_reconversion' do
    it 'queues the reconversion and goes back to the site settings' do
      allow(BulkReconversionService).to receive(:new).and_return(instance_double(BulkReconversionService, request_all: 4))
      post :create
      expect(response).to redirect_to '/admin/site_settings/'
      expect(flash[:notice]).to eq(I18n.t(:bulk_reconversion_requested, count: 4))
    end
  end
end
