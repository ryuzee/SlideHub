require 'rails_helper'

RSpec.describe PlayerController, type: :controller do
  let(:slide) { create(:slide) }
  render_views

  describe 'GET #show' do
    it 'succeeds to return encrypted JavaScript' do
      get :show, params: { id: slide.id }
      expect(response.status).to eq(200)
      updated_data = Slide.find(slide.id)
      expect(updated_data.embedded_view).to eq(slide.embedded_view + 1)
      expect(updated_data.total_view).to eq(slide.total_view + 1)
    end

    it 'succeeds to return encrypted JavaScript for inside' do
      get :show, params: { id: slide.id, inside: 1 }
      expect(response.status).to eq(200)
      updated_data = Slide.find(slide.id)
      expect(updated_data.embedded_view).to eq(slide.embedded_view)
      expect(updated_data.total_view).to eq(slide.total_view)
    end
  end

  describe 'the player script' do
    before { PlayerScript.clear }

    it 'is minified once and reused for later requests' do
      expect(Terser).to receive(:new).once.and_call_original
      get :show_v2, params: { id: slide.id, prefix: 'jsfirst', inside: 1 }
      get :show_v2, params: { id: slide.id, prefix: 'jssecond', inside: 1 }
      expect(response.body).to include('OSSJSPARTSjssecond')
      expect(response.body).not_to include(PlayerScript::START_INDEX)
    end

    it 'starts from the page in the URL' do
      get :show_v2, params: { id: slide.id, page: 3, prefix: 'jsstart', inside: 1 }
      expect(response.body).to include('OSSJSPARTSjsstart.currentPageIndex=2')
    end

    it 'uses its own prefix instead of one that is not a simple name' do
      get :show_v2, params: { id: slide.id, prefix: 'x;alert(1)//', inside: 1 }
      expect(response.body).not_to include('alert(1)')
      expect(response.body).to match(/OSSJSPARTSjs[0-9a-f]{32}/)
    end
  end
end
