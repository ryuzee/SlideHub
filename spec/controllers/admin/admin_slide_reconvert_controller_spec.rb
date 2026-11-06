require 'rails_helper'

RSpec.describe Admin::SlideReconvertController, type: :controller do
  describe 'Slides' do
    render_views
    let(:admin_user) { create(:admin_user) }
    before do
      login_by_admin_user admin_user
    end

    describe 'GET /admin/slide_reconvert/1' do
      it 'asks to reconvert into a new key and keeps the current key until it finishes' do
        slide = create(:slide)
        expect(CloudConfig.provider).to receive(:send_message) do |message|
          body = JSON.parse(message)
          expect(body['object_key']).to eq(slide.object_key)
          expect(body['new_object_key']).to match(/\A[0-9a-f]{32}\z/)
          expect(body['new_object_key']).not_to eq(slide.object_key)
        end
        get :show, params: { id: slide.id }
        expect(response.status).to eq(302)
        expect(Slide.find(slide.id).object_key).to eq(slide.object_key)
      end
    end
  end
end
