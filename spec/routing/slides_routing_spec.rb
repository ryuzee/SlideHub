describe SlidesController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get('/slides')).to route_to('slides#index')
    end

    it 'routes to #latest' do
      expect(get('/slides/latest')).to route_to('slides#latest')
    end

    it 'routes to #popular' do
      expect(get('/slides/popular')).to route_to('slides#popular')
    end

    it 'routes to #search' do
      expect(get('/slides/search')).to route_to('slides#search')
    end

    it 'routes to #new' do
      expect(get('/slides/new')).to route_to('slides#new')
    end

    it 'routes to #show' do
      expect(get('/slides/1')).to route_to('slides#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get('/slides/1/edit')).to route_to('slides#edit', id: '1')
    end

    it 'routes to #download' do
      expect(get('/slides/1/download')).to route_to('slides#download', id: '1')
    end

    it 'routes to #update_view' do
      expect(get('/slides/1/update_view')).to route_to('slides#update_view', id: '1')
    end

    it 'routes to #embedded' do
      expect(get('/slides/1/embedded')).to route_to('slides#embedded', id: '1')
    end

    it 'routes to #create' do
      expect(post('/slides')).to route_to('slides#create')
    end

    it 'routes to #update' do
      expect(put('/slides/1')).to route_to('slides#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete('/slides/1')).to route_to('slides#destroy', id: '1')
    end
    # @TODO: need to add compatibility check with previous version
  end
end
