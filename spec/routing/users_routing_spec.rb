require 'rails_helper'

describe UsersController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get('/users')).to route_to('users#index')
    end

    it 'routes to #show' do
      expect(get('/users/1')).to route_to('users#show', id: '1')
    end

    it 'routes to #embedded' do
      expect(get('/users/1/embedded')).to route_to('users#embedded', id: '1')
    end

    it 'routes to #sign_up' do
      expect(get('/users/sign_up')).to route_to('users/registrations#new')
    end

    it 'routes to #edit' do
      expect(get('/users/1/edit')).to route_to('users#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post('/users')).to route_to('users/registrations#create')
    end

    it 'routes to #update' do
      expect(put('/users/1')).to route_to('users#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete('/users/1')).to route_to('users#destroy', id: '1')
    end

    it 'routes to #show by username' do
      user = create(:default_user)
      expect(get("/#{user.username}")).to route_to('users#show', username: user.username)
    end
  end
end
