require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  let(:auth) do
    OmniAuth::AuthHash.new(provider: 'twitter', uid: '987654',
                           info: { nickname: 'newcomer', name: 'New Comer', description: 'Bio' },
                           credentials: { token: 'token' })
  end

  before do
    request.env['devise.mapping'] = Devise.mappings[:user]
    request.env['omniauth.auth'] = auth
  end

  after { ApplicationSetting['site.signup_enabled'] = '1' }

  context 'when sign-up is disabled' do
    before { ApplicationSetting['site.signup_enabled'] = '0' }

    it 'does not create an account for someone who has not registered' do
      expect { get :twitter }.not_to change(User, :count)
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to eq(I18n.t(:account_not_registered))
    end

    it 'signs in someone who has already registered' do
      user = create(:default_user, provider: 'twitter', uid: '987654')
      get :twitter
      expect(controller.current_user).to eq(user)
    end
  end

  context 'when sign-up is enabled' do
    before { ApplicationSetting['site.signup_enabled'] = '1' }

    it 'sends someone who has not registered to the sign-up page to finish' do
      get :twitter
      expect(response).to redirect_to(new_user_registration_url)
    end
  end

  describe 'Facebook' do
    let(:auth) do
      OmniAuth::AuthHash.new(provider: 'facebook', uid: 'fb-1', info: { email: 'fb@example.com' },
                             extra: { raw_info: { username: 'fbuser', name: 'FB User' } }, credentials: { token: 't' })
    end

    it 'signs in someone who has already registered' do
      user = create(:default_user, provider: 'facebook', uid: 'fb-1')
      get :facebook
      expect(controller.current_user).to eq(user)
    end

    it 'does not create an account for someone new while sign-up is disabled' do
      ApplicationSetting['site.signup_enabled'] = '0'
      expect { get :facebook }.not_to change(User, :count)
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'sends someone new to the sign-up page with what Facebook told us' do
      ApplicationSetting['site.signup_enabled'] = '1'
      get :facebook
      expect(response).to redirect_to(new_user_registration_url)
      expect(session['devise.user_attributes']).to include('email' => 'fb@example.com', 'username' => 'fbuser')
    end
  end

  describe 'SAML' do
    let(:auth) do
      OmniAuth::AuthHash.new(provider: 'saml', uid: 'saml-1', info: { email: 'saml@example.com' },
                             extra: { raw_info: { 'username' => 'samluser', 'first_name' => 'Taro', 'last_name' => 'Yamada' } })
    end

    it 'signs in someone who has already registered' do
      user = create(:default_user, provider: 'saml', uid: 'saml-1')
      post :saml
      expect(controller.current_user).to eq(user)
    end

    it 'sends someone new to the sign-up page with the attributes from the identity provider' do
      post :saml
      expect(response).to redirect_to(new_user_registration_url)
      expect(session['devise.user_attributes']).to include('username' => 'samluser', 'display_name' => 'Yamada Taro',
                                                           'email' => 'saml@example.com')
    end
  end
end
