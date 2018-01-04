require 'rails_helper'

describe Admin::SlideDownloadController do
  describe 'routing' do
    it 'routes to #show' do
      expect(get('/admin/slide_download/1')).to route_to('admin/slide_download#show', id: '1')
    end
  end
end
