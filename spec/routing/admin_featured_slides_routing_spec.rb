require 'rails_helper'

describe Admin::FeaturedSlidesController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get('/admin/featured_slides/')).to route_to('admin/featured_slides#index')
    end
  end
end
