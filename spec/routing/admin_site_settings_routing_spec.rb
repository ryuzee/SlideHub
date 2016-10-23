require 'rails_helper'

describe Admin::SiteSettingsController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get('/admin/site_settings/')).to route_to('admin/site_settings#index')
    end
  end
end
