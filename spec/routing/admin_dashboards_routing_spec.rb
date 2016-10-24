require 'rails_helper'

describe Admin::DashboardsController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get('/admin/dashboards/')).to route_to('admin/dashboards#index')
    end
  end
end
