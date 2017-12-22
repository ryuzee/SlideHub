require 'rails_helper'

describe 'authentication' do
  before do
    set_omniauth
    Rails.application.env_config['devise.mapping'] = Devise.mappings[:user]
    Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:facebook]
  end

  subject { get '/users/auth/facebook' }

  it 'Callback from Facebook' do
    expect(subject).to redirect_to '/users/auth/facebook/callback'
  end
end
