require 'rails_helper'

describe StatisticsController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get('/statistics/index')).to route_to('statistics#index')
    end
  end
end
