require 'rails_helper'

describe Admin::CustomContentsController do
  describe 'routing' do
    it 'routes to #custom_contents' do
      expect(get('/admin/custom_contents/')).to route_to('admin/custom_contents#index')
    end
  end
end
