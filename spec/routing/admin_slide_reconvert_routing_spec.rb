require 'rails_helper'

describe Admin::SlideReconvertController do
  describe 'routing' do
    it 'routes to #show' do
      expect(get('/admin/slide_reconvert/1')).to route_to('admin/slide_reconvert#show', id: '1')
    end
  end
end
