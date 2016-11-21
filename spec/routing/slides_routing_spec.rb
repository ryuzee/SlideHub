# == Schema Information
#
# Table name: slides
#
#  id             :integer          not null, primary key
#  user_id        :integer          not null
#  name           :string(255)      not null
#  description    :text(65535)      not null
#  downloadable   :boolean          default(FALSE), not null
#  category_id    :integer          not null
#  created_at     :datetime         not null
#  modified_at    :datetime
#  key            :string(255)      default("")
#  extension      :string(10)       default(""), not null
#  convert_status :integer          default(0)
#  total_view     :integer          default(0), not null
#  page_view      :integer          default(0)
#  download_count :integer          default(0), not null
#  embedded_view  :integer          default(0), not null
#  num_of_pages   :integer          default(0)
#  comments_count :integer          default(0), not null
#

require 'rails_helper'

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

    # backward compatibility
    it 'routes to #index (BC)' do
      expect(get('/slides/index')).to route_to('slides#index')
    end

    it 'routes to #show (BC)' do
      expect(get('/slides/view/1')).to route_to('slides#show', id: '1')
    end

    it 'routes to #download (BC)' do
      expect(get('/slides/download/1')).to route_to('slides#download', id: '1')
    end

    it 'routes to #embedded (BC)' do
      expect(get('/slides/embedded/1')).to route_to('slides#embedded', id: '1')
    end

    it 'routes to #latest.rss' do
      expect(get('/slides/latest.rss')).to route_to('slides#latest', 'format' => 'rss')
    end

    it 'routes to #popular.rss' do
      expect(get('/slides/popular.rss')).to route_to('slides#popular', 'format' => 'rss')
    end

    ## specify page number when displaying a slide
    it 'routes to #show/:id/:page' do
      expect(get('/slides/1/2')).to route_to('slides#show', id: '1', page: '2')
    end

    it 'routes to #embedded/:id/:page' do
      expect(get('/slides/1/embedded/2')).to route_to('slides#embedded', id: '1', page: '2')
    end

    it 'routes to #slides/embedded/:id/:page' do
      expect(get('/slides/embedded/1/2')).to route_to('slides#embedded', id: '1', page: '2')
    end
  end
end
