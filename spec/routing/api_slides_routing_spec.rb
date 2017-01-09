require 'rails_helper'

describe Api::V1::SlidesController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get('/api/v1/slides')).to route_to('api/v1/slides#index', format: 'json')
    end

    it 'routes to #show' do
      expect(get('/api/v1/slides/1')).to route_to('api/v1/slides#show', id: '1', format: 'json')
    end

    it 'routes to #transcript' do
      expect(get('/api/v1/slides/1/transcript')).to route_to('api/v1/slides#transcript', id: '1', format: 'json')
    end
  end
end
