require 'rails_helper'

describe 'UserFinder' do
  let(:user) { build(:default_user) }

  describe 'username_to_id' do
    it 'returns user_id' do
      default_user = FactoryBot.create(:default_user)
      id = UserFinder.username_to_id(default_user.username)
      expect(id).to eq(1)
    end
  end

  describe 'omniauth_with_Twitter' do
    auth_hash = OmniAuth::AuthHash.new({
      provider: 'twitter',
      uid: '1234',
      info: {
        nickname: 'test',
        name: 'Foo Bar',
        description: 'Bio',
      },
      credentials: {
        token: 'token123456789012345',
      },
    })

    it 'retrieves an existing user' do
      user = User.new(
        provider: 'twitter',
        uid: 1234,
        email: 'user@example.com',
        display_name: 'Foo Bar',
        biography: 'Bio',
        username: 'test',
        token: 'token123456789012345',
        password: 'token123456789012345',
        password_confirmation: 'token123456789012345',
      )
      user.save
      omniauth_user = UserFinder.find_for_twitter_oauth(auth_hash)

      expect(user).to eq(omniauth_user)
    end

    it "creates a new user if one doesn't already exist" do
      omniauth_user = UserFinder.find_for_twitter_oauth(auth_hash)
      expect(omniauth_user.id).to eq(nil)
      expect(omniauth_user.username).to eq('test')
    end
  end

  describe 'omniauth_with_Facebook' do
    auth_hash = OmniAuth::AuthHash.new({
      provider: 'facebook',
      uid: '1234',
      info: {
        email: 'user@example.com',
      },
      extra: {
        raw_info: {
          username: '',
          name: 'Foo Bar',
        },
      },
      credentials: {
        token: 'token123456789012345',
      },
    })

    it 'retrieves an existing user' do
      user = User.new(
        provider: 'facebook',
        uid: 1234,
        email: 'user@example.com',
        display_name: 'Foo Bar',
        biography: 'Bio',
        username: 'test',
        token: 'token123456789012345',
        password: 'token123456789012345',
        password_confirmation: 'token123456789012345',
      )
      user.save
      omniauth_user = UserFinder.find_for_facebook_oauth(auth_hash)

      expect(user).to eq(omniauth_user)
    end

    it "creates a new user if one doesn't already exist" do
      omniauth_user = UserFinder.find_for_facebook_oauth(auth_hash)
      expect(omniauth_user.id).to eq(nil)
      expect(omniauth_user.email).to eq('user@example.com')
    end
  end
end
