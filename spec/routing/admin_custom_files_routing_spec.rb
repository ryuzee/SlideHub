require 'rails_helper'

describe Admin::CustomFilesController do
  describe 'routing custom_files' do
    it 'routes to #index' do
      expect(get('/admin/custom_files/')).to route_to('admin/custom_files#index')
    end

    it 'routes to #new' do
      expect(get('/admin/custom_files/new')).to route_to('admin/custom_files#new')
    end

    it 'routes to #create' do
      expect(post('/admin/custom_files')).to route_to('admin/custom_files#create')
    end

    it 'routes to #destroy' do
      expect(delete('/admin/custom_files/1')).to route_to('admin/custom_files#destroy', id: '1')
    end
  end
end
