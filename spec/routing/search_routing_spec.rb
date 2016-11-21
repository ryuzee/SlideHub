require 'rails_helper'

describe SearchController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get('/search')).to route_to('search#index')
    end
  end
end
