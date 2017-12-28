require 'rails_helper'

describe Admin::LogsController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get('/admin/logs/index')).to route_to('admin/logs#index')
    end

    it 'routes to #show' do
      expect(get('/admin/logs/show?path=a')).to route_to('admin/logs#show', path: 'a')
    end

    it 'routes to #download' do
      expect(get('/admin/logs/download?path=a')).to route_to('admin/logs#download', path: 'a')
    end
  end
end
