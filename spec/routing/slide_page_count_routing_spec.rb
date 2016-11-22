require 'rails_helper'

describe SlidePageCountController do
  describe 'routing' do
    it 'routes to #show' do
      expect(get('/page_count/1')).to route_to('slide_page_count#show', id: '1')
    end
  end
end
