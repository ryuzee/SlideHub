require 'rails_helper'

RSpec.describe Admin::ThumbnailRegenerationsController, type: :controller do
  let(:admin_user) { create(:admin_user) }

  before do
    login_by_admin_user admin_user
  end

  after do
    ApplicationSetting[ThumbnailRegenerationProgress::REQUESTED_AT_KEY] = ''
    ApplicationSetting[ThumbnailRegenerationProgress::REQUESTED_COUNT_KEY] = '0'
  end

  describe 'POST /admin/thumbnail_regeneration' do
    it 'queues regeneration, records the request and redirects to site settings' do
      allow(ThumbnailRegenerationService).to receive(:new).and_return(instance_double(ThumbnailRegenerationService, request_all: 3))
      post :create
      expect(response).to redirect_to '/admin/site_settings/'
      expect(flash[:notice]).to eq(I18n.t(:regenerate_thumbnails_requested, count: 3))
      expect(ApplicationSetting[ThumbnailRegenerationProgress::REQUESTED_COUNT_KEY]).to eq('3')
    end
  end

  describe 'GET /admin/thumbnail_regeneration.json' do
    it 'returns the estimated progress from the queue length' do
      ThumbnailRegenerationProgress.record(10)
      allow(CloudConfig.provider).to receive(:queue_length).and_return(4)
      get :show, format: :json
      body = JSON.parse(response.body)
      expect(body).to include('requested' => true, 'requested_count' => 10, 'done' => 6, 'remaining' => 4, 'finished' => false)
      expect(body['estimated_seconds']).to be_positive
    end
  end
end
