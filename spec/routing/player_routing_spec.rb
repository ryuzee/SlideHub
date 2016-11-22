require 'rails_helper'

describe PlayerController do
  describe 'routing' do
    it 'routes to #show' do
      expect(get('/player/1')).to route_to('player#show', id: '1')
    end

    it 'routes to #show/:id/:page' do
      expect(get('/player/1/2')).to route_to('player#show', id: '1', page: '2')
    end

    it 'routes to #show (BC)' do
      expect(get('/slides/1/embedded')).to route_to('player#show', id: '1')
    end

    it 'routes to #show (BC)' do
      expect(get('/slides/embedded/1')).to route_to('player#show', id: '1')
    end

    it 'routes to #show/:id/:page (BC)' do
      expect(get('/slides/1/embedded/2')).to route_to('player#show', id: '1', page: '2')
    end

    it 'routes to #show/:id/:page (BC)' do
      expect(get('/slides/embedded/1/2')).to route_to('player#show', id: '1', page: '2')
    end
  end
end
