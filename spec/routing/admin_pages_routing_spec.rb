require 'rails_helper'

describe Admin::PagesController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get('/admin/pages')).to route_to('admin/pages#index')
    end

    it 'routes to #edit' do
      expect(get('/admin/pages/1/edit')).to route_to('admin/pages#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post('/admin/pages')).to route_to('admin/pages#create')
    end

    it 'routes to #update' do
      expect(put('/admin/pages/1')).to route_to('admin/pages#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete('/admin/pages/1')).to route_to('admin/pages#destroy', id: '1')
    end
  end
end
