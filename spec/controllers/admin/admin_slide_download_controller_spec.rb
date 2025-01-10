require 'rails_helper'

RSpec.describe Admin::SlideDownloadController, type: :controller do
  describe 'Slides' do
    render_views
    let(:admin_user) { create(:admin_user) }
    before do
      login_by_admin_user admin_user
    end

    describe 'GET /admin/slide_download/1' do
      it 'works!' do
        allow(SlideHub::Cloud::Engine::Aws).to receive(:get_slide_download_url).and_return('http://www.example.com/1.pdf')
        allow(SlideHub::Cloud::Engine::Azure).to receive(:get_slide_download_url).and_return('http://www.example.com/1.pdf')
        stub_request(:any, 'http://www.example.com/1.pdf').to_return(
          body: 'test',
          status: 200,
        )
        slide = create(:slide)
        get :show, params: { id: slide.id }
        expect(response.status).to eq(200)
        expect(response.headers['Content-Disposition']).to match(/attachment; filename="#{slide.object_key}#{slide.extension}"/)
      end
    end
  end
end
