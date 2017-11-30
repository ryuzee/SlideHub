require 'rails_helper'

RSpec.describe Custom::CssController, type: :controller do
  describe 'CustomCss' do
    describe 'GET /custom/override.css' do
      it 'works!' do
        get 'show', format: 'css'
        expect(response).to render_template :show
        expect(response.status).to eq(200)
      end

      it 'does not respond to html request!' do
        expect { get('show', format: 'html') }.to raise_error(ActionController::UnknownFormat)
      end
    end
  end
end
