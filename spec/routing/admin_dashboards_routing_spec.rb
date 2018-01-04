require 'rails_helper'

describe Admin::DashboardsController do
  describe 'routing' do
    it 'routes to #show' do
      expect(get('/admin/dashboard')).to route_to('admin/dashboards#show')
    end
  end
end
