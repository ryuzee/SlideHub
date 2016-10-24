require 'rails_helper'

describe Admin::UsersController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get('/admin/users/')).to route_to('admin/users#index')
    end
  end
end
