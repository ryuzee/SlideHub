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

RSpec.describe UsersController, type: :controller do
  let!(:default_user) { create(:default_user) }

  describe 'When the user has logged in' do
    before do
      login_by_user default_user
    end

    describe 'GET /users/index' do
      it 'shows the page for the user' do
        get 'index'
        expect(response.status).to eq(200)
      end
    end
  end

  describe 'When the user has not logged in' do
    describe 'GET /users/1' do
      it 'shows the user public page via user_id' do
        get 'show', params: { id: '1' }
        expect(response.status).to eq(200)
      end
    end

    describe 'GET /users/user01' do
      it 'shows the user public page via username' do
        get 'show', params: { username: 'user01' }
        expect(response.status).to eq(200)
      end
    end

    describe 'GET /users/1?sort_by=popularity' do
      it 'shows the user public page and the slides are sorted by popularity' do
        get 'show', params: { id: '1', sort_by: 'popularity' }
        expect(response.status).to eq(200)
      end
    end

    describe 'GET /users/1/embedded' do
      it 'returns javascript for embedding' do
        get 'embedded', params: { id: '1' }
        expect(response.status).to eq(200)
      end
    end

    describe 'GET /users/index' do
      it 'redirects to login page' do
        get 'index'
        expect(response.status).to eq(302)
      end
    end
  end
end
