require 'rails_helper'

# 管理画面の「サインアップを有効にする」の設定
describe 'Sign-up switch' do
  let(:user_params) do
    { user: { email: 'new@example.com', password: 'Passw0rd!x', password_confirmation: 'Passw0rd!x',
              username: 'newuser', display_name: 'New', biography: 'Hello' } }
  end

  after { ApplicationSetting['site.signup_enabled'] = '1' }

  context 'when sign-up is disabled' do
    before { ApplicationSetting['site.signup_enabled'] = '0' }

    it 'does not show the sign-up page, whatever the method' do
      get '/users/sign_up'
      expect(response.status).to eq(404)
      head '/users/sign_up'
      expect(response.status).to eq(404)
    end

    it 'does not create an account from a submitted form' do
      expect { post '/users', params: user_params }.not_to change(User, :count)
      expect(response.status).to eq(404)
    end

    it 'still shows the sign-in page' do
      get '/users/sign_in'
      expect(response.status).to eq(200)
    end
  end

  context 'when sign-up is enabled' do
    before { ApplicationSetting['site.signup_enabled'] = '1' }

    it 'creates an account' do
      get '/users/sign_up'
      expect(response.status).to eq(200)
      expect { post '/users', params: user_params }.to change(User, :count).by(1)
    end
  end
end
