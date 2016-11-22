require 'rails_helper'

describe SlideDownloadController do
  describe 'routing' do
    it 'routes to #download' do
      expect(get('/download/1')).to route_to('slide_download#show', id: '1')
    end

    it 'routes to #download (BC)' do
      expect(get('/slides/1/download')).to route_to('slide_download#show', id: '1')
    end

    it 'routes to #download (BC)' do
      expect(get('/slides/download/1')).to route_to('slide_download#show', id: '1')
    end
  end
end
