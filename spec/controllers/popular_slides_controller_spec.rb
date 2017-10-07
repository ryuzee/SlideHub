require 'rails_helper'

RSpec.describe PopularSlidesController, type: :controller do
  let(:slide) { create(:slide) }

  describe 'GET #index' do
    it 'render index' do
      get :index
      expect(response.status).to eq(200)
      expect(response).to render_template :index
    end
  end
end
