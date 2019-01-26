require 'rails_helper'

RSpec.describe Admin::SlideReconvertController, type: :controller do
  describe 'Slides' do
    let(:admin_user) { create(:admin_user) }
    before do
      login_by_admin_user admin_user
    end

    describe 'GET /admin/slide_reconvert/1' do
      it 'works!' do
        allow_any_instance_of(SlideConvertService).to receive(:send_request).and_return(true)
        slide = create(:slide)
        get :show, params: { id: slide.id }
        expect(response.status).to eq(302)
      end
    end
  end
end
