require 'rails_helper'

describe LatestController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get('/latest')).to route_to('latest#index')
    end

    it 'routes to #index (BC)' do
      expect(get('/slides/latest')).to route_to('latest#index')
    end

    it 'routes to #index.rss' do
      expect(get('/latest.rss')).to route_to('latest#index', 'format' => 'rss')
    end

    it 'routes to #index.rss (BC)' do
      expect(get('/slides/latest.rss')).to route_to('latest#index', 'format' => 'rss')
    end
  end
end
