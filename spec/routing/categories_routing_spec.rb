require 'rails_helper'

describe CategoriesController do
  describe 'routing' do
    it 'routes to #category' do
      expect(get('/categories/1')).to route_to(controller: 'categories', action: 'show', id: '1')
    end
  end
end
