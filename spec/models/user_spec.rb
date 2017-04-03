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
#  username               :string(255)      not null
#

require 'spec_helper'
require 'rails_helper'

describe 'User' do
  let(:user) { build(:general_user) }

  describe 'valid usernames' do
    it 'can be accepted' do
      valid_usernames = %w(
        ryuzee
        ryuzee-1234
        ryuzee_1234
        RYUZEE
        ryu
      )
      expect(user).to allow_value(*valid_usernames).for(:username)
    end
  end

  describe 'invalid usernames' do
    it 'can not be accepted' do
      invalid_usernames = [
        'ryuzee@example.com',
        '-ryuzee',
        'ryuzee-',
        'ryu zee',
        'ry',
        'ryuzee789012345678901234567890123',
        'a#b',
        'a' * (32 + 1),
        'search',
        'admin',
        'slides',
        'users',
        'categories',
        'popular',
        'latest',
        'statistics',
        'dashboard',
        'dashboards',
        'api',
        'www',
        'blog',
        'image',
        'rss',
      ]
      expect(user).not_to allow_value(*invalid_usernames).for(:username)
    end
  end

  describe 'valid passwords' do
    it 'can be accepted' do
      valid_passwords = %w(
        12345678
        abcdefgh
        abc12345
        #123abc$
      )
      expect(user).to allow_value(*valid_passwords).for(:password)
    end
  end

  describe 'invalid passwords (0..7)' do
    it 'can not be accepted' do
      invalid_passwords =[
        'abcdefg',
        ' ' * 8,
      ]
      expect(user).not_to allow_value(*invalid_passwords).for(:password)
    end
  end

  describe 'valid emails' do
    it 'can be accepted' do
      valid_emails = %w(
        ryuzee@example.com
        ryuzee@jp.example.com
        ryuzee@tt
      )
      expect(user).to allow_value(*valid_emails).for(:email)
    end
  end

  describe 'invalid emails' do
    it 'can not be accepted' do
      invalid_emails =[
        'www.example.com',
        'examplecom'
      ]
      expect(user).not_to allow_value(*invalid_emails).for(:email)
    end
  end

  describe 'invalid display names' do
    it 'can not be accepted' do
      invalid_usernames = [
        'a' * (32 + 1),
        ' ' * (32 + 1),
      ]
      expect(user).not_to allow_value(*invalid_usernames).for(:display_name)
    end
  end

  describe 'Creating "User" model' do
    success_data = { email: 'dummy1@example.com', username: 'dummy1', password: 'dummy12345', display_name: 'dummy1', biography: 'dummy1' }
    it 'is valid with email, username, password, display_name, biography' do
      user = User.new(success_data)
      expect(user.valid?).to eq(true)
    end

    it 'is invalid without email' do
      data = success_data.dup
      data.delete(:email)
      user = User.new(data)
      expect(user.valid?).to eq(false)
    end

    it 'is invalid without password' do
      data = success_data.dup
      data.delete(:password)
      user = User.new(data)
      expect(user.valid?).to eq(false)
    end

    it 'is invalid without username' do
      data = success_data.dup
      data.delete(:username)
      user = User.new(data)
      expect(user.valid?).to eq(false)
    end

    it 'is invalid without display_name' do
      data = success_data.dup
      data.delete(:display_name)
      user = User.new(data)
      expect(user.valid?).to eq(false)
    end

    it 'is invalid without biography' do
      data = success_data.dup
      data.delete(:biography)
      user = User.new(data)
      expect(user.valid?).to eq(false)
    end

    it 'is invalid with a username that is already used by others' do
      general_user = FactoryGirl.create(:general_user)
      data = success_data.dup
      data[:username] = general_user[:username]
      user = User.new(data)
      expect(user.valid?).to eq(false)
    end

    it 'is invalid with an email that is already used by others' do
      general_user = FactoryGirl.create(:general_user)
      data = success_data.dup
      data[:email] = general_user[:email]
      user = User.new(data)
      expect(user.valid?).to eq(false)
    end
  end

  describe 'username_to_id' do
    it 'returns user_id' do
      general_user = FactoryGirl.create(:general_user)
      id = User.username_to_id(general_user.username)
      expect(id).to eq(998)
    end
  end
end
