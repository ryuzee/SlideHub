# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(32)       not null
#  display_name           :string(128)      not null
#  password               :string(255)      default(""), not null
#  admin                  :boolean          default(FALSE), not null
#  disabled               :boolean          default(FALSE)
#  created_at             :datetime         not null
#  updated_at             :datetime
#  biography              :text(65535)
#  slides_count           :integer          default(0)
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  avatar_file_name       :string(255)
#  avatar_content_type    :string(255)
#  avatar_file_size       :integer
#  avatar_updated_at      :datetime
#

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
