require 'rails_helper'

describe Api::V1::UsersController do
  describe 'routing' do
    it 'routes to #show' do
      expect(get('/api/v1/users/1')).to route_to('api/v1/users#show', id: '1', format: 'json')
    end
  end
end
