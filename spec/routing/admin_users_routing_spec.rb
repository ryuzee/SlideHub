require 'rails_helper'

describe Admin::UsersController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get('/admin/users/')).to route_to('admin/users#index')
    end

    it 'routes to #edit' do
      expect(get('/admin/users/1/edit')).to route_to('admin/users#edit', id: '1')
    end

    it 'routes to #update' do
      expect(put('/admin/users/1')).to route_to('admin/users#update', id: '1')
    end
  end
end
