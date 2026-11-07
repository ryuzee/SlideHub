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
end
