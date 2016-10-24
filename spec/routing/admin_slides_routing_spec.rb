require 'rails_helper'

describe Admin::SlidesController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get('/admin/slides/')).to route_to('admin/slides#index')
    end

    it 'routes to #edit' do
      expect(get('/admin/slides/1/edit')).to route_to('admin/slides#edit', id: '1')
    end

    it 'routes to #update' do
      expect(put('/admin/slides/1')).to route_to('admin/slides#update', id: '1')
    end
  end
end
