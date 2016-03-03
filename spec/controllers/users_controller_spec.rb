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
#  modified_at            :datetime
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
  describe 'When logged in' do
    let(:general_user) { create(:general_user) }
    before do
      login_by_user general_user
    end

    describe 'GET /users/index' do
      it 'works!' do
        get 'index'
        expect(response.status).to eq(200)
      end
    end

    describe 'GET /users/statistics' do
      it 'works!' do
        get 'statistics'
        expect(response.status).to eq(200)
      end
    end
  end

  describe 'No Login' do
    describe 'GET /users/998' do
      it 'works!' do
        create(:general_user)
        get 'show', id: '998'
        expect(response.status).to eq(200)
      end
    end

    describe 'GET /users/index' do
      it 'redirect to login' do
        get 'index'
        expect(response.status).to eq(302)
      end
    end

    describe 'GET /users/statistics' do
      it 'redirect to login' do
        get 'index'
        expect(response.status).to eq(302)
      end
    end
  end
end
