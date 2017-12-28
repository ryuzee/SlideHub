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

describe 'Users' do
  describe 'GET /users/sign_in' do
    it 'works!' do
      get '/users/sign_in'
      expect(response.status).to eq(200)
    end
  end

  describe 'GET /users/sign_up' do
    it 'works!' do
      get '/users/sign_up'
      expect(response.status).to eq(200)
    end
  end

  describe 'GET /users/1' do
    it 'works!' do
      create(:slide)
      get '/users/1'
      expect(response.status).to eq(200)
    end
  end

  describe 'GET /users/view/1 (Backward Compatibility)' do
    it 'works!' do
      create(:slide)
      get '/users/view/1'
      expect(response.status).to eq(200)
    end
  end
end
