require 'rails_helper'

RSpec.describe SlideDownloadController, type: :controller do
  let(:slide) { create(:slide) }

  describe 'GET #show' do
    it 'success to download file' do
      allow(SlideHub::Cloud::Engine::AWS).to receive(:get_slide_download_url).and_return('http://www.example.com/1.pdf')
      allow(SlideHub::Cloud::Engine::Azure).to receive(:get_slide_download_url).and_return('http://www.example.com/1.pdf')
      stub_request(:any, 'http://www.example.com/1.pdf').to_return(
        body: 'test',
        status: 200,
      )
      get :show, params: { id: slide.id }
      expect(response.status).to eq(200)
      expect(response.headers['Content-Disposition']).to match(/attachment; filename="#{slide.object_key}#{slide.extension}"/)
    end

    it 'fails to download file because of permission' do
      FactoryBot.create(:slide)
      slide.downloadable = false
      slide.save
      get :show, params: { id: slide.id }
      expect(response.status).to eq(302)
    end
  end
end
