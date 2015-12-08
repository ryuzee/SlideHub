describe ManagementsController do
  describe 'routing' do
    it 'routes to #dashboard' do
      expect(get('/managements/dashboard')).to route_to('managements#dashboard')
    end

    it 'routes to #slide_list' do
      expect(get('/managements/slide_list')).to route_to('managements#slide_list')
    end

    it 'routes to #user_list' do
      expect(get('/managements/user_list')).to route_to('managements#user_list')
    end

    it 'routes to #site_setting' do
      expect(get('/managements/site_setting')).to route_to('managements#site_setting')
    end

    it 'routes to #custom_contents_setting' do
      expect(get('/managements/custom_contents_setting')).to route_to('managements#custom_contents_setting')
    end

    it 'routes to #edit' do
      expect(get('/managements/slide_edit/1')).to route_to('managements#slide_edit', id: '1')
    end

    it 'routes to #slide_update' do
      expect(post('/managements/slide_update')).to route_to('managements#slide_update')
    end
  end
end
