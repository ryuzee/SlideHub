require 'rails_helper'

describe PopularSlidesController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get('/popular')).to route_to('popular_slides#index')
    end

    it 'routes to #index (BC)' do
      expect(get('/slides/popular')).to route_to('popular_slides#index')
    end

    it 'routes to #index.rss' do
      expect(get('/popular.rss')).to route_to('popular_slides#index', 'format' => 'rss')
    end

    it 'routes to #index.rss (BC)' do
      expect(get('/slides/popular.rss')).to route_to('popular_slides#index', 'format' => 'rss')
    end
  end
end
