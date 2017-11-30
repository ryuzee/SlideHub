require 'rails_helper'

describe Custom::CssController do
  describe 'routing' do
    it 'routes to #override.css' do
      expect(get('/custom/override.css')).to route_to('custom/css#show', format: 'css')
    end
  end
end
