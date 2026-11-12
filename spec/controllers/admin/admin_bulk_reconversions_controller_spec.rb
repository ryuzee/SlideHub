require 'rails_helper'

RSpec.describe Admin::BulkReconversionsController, type: :controller do
  before do
    login_by_admin_user create(:admin_user)
  end

  after do
    [BulkReconversionProgress, ThumbnailRegenerationProgress].each do |klass|
      ApplicationSetting[klass::REQUESTED_AT_KEY] = ''
      ApplicationSetting[klass::REQUESTED_COUNT_KEY] = '0'
      ApplicationSetting[klass::FINISHED_AT_KEY] = ''
    end
  end

  describe 'POST /admin/bulk_reconversion' do
    it 'queues the reconversion, records the request and goes back to the site settings' do
      allow(CloudConfig.provider).to receive(:queue_length).and_return(0)
      allow(BulkReconversionService).to receive(:new).and_return(instance_double(BulkReconversionService, request_all: 4))
      post :create
      expect(response).to redirect_to '/admin/site_settings/'
      expect(flash[:notice]).to eq(I18n.t(:bulk_reconversion_requested, count: 4))
      expect(ApplicationSetting[BulkReconversionProgress::REQUESTED_COUNT_KEY]).to eq('4')
    end

    it 'keeps a finished thumbnail regeneration finished after the queue fills up again' do
      ThumbnailRegenerationProgress.record(10, now: 10.minutes.ago)
      allow(CloudConfig.provider).to receive(:queue_length).and_return(0)
      allow(BulkReconversionService).to receive(:new).and_return(instance_double(BulkReconversionService, request_all: 4))
      post :create
      expect(ThumbnailRegenerationProgress.new(queue_length: 4).finished?).to be(true)
    end
  end

  describe 'GET /admin/bulk_reconversion.json' do
    it 'returns the estimated progress' do
      BulkReconversionProgress.record(10)
      create(:slide)
      allow(CloudConfig.provider).to receive(:queue_length).and_return(4)
      get :show, format: :json
      body = JSON.parse(response.body)
      expect(body).to include('requested' => true, 'requested_count' => 10, 'remaining' => 1, 'done' => 9, 'finished' => false)
    end
  end
end
