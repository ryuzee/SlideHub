require 'rails_helper'

RSpec.describe Custom::CssController, type: :controller do
  render_views

  describe 'CustomCss' do
    describe 'GET /custom/override.css' do
      it 'returns the custom CSS from the settings' do
        ApplicationSetting['custom_content.css'] = '.custom-banner { color: red; }'
        get 'show', format: 'css'
        expect(response).to render_template :show
        expect(response.status).to eq(200)
        expect(response.media_type).to eq('text/css')
        expect(response.body).to include('.custom-banner { color: red; }')
      end

      it 'does not respond to html request!' do
        expect { get('show', format: 'html') }.to raise_error(ActionController::UnknownFormat)
      end
    end
  end
end
