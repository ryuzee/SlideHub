require 'rails_helper'

describe Admin::FeaturedSlidesController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get('/admin/featured_slides/')).to route_to('admin/featured_slides#index')
    end

    it 'routes to #reorder' do
      expect(patch('/admin/featured_slides/reorder')).to route_to('admin/featured_slides#reorder')
    end
  end
end
