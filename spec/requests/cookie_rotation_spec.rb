require 'rails_helper'

# Rails の初期設定を 8.1 に上げると、Cookie の署名に使う鍵の作り方が SHA1 から SHA256 に変わる。
# 上げる前に発行した「ログインしたままにする」の Cookie でも、ログインしたままでいられることを確かめる
describe 'Cookies issued before the defaults were raised' do
  let(:user) { create(:default_user) }

  # Rails 5.1 の初期設定のときと同じ作り方で、署名付き Cookie の値を作る
  def old_signed_cookie(value)
    config = Rails.application.config.action_dispatch
    key_generator = ActiveSupport::KeyGenerator.new(
      Rails.application.secret_key_base, iterations: 1000, hash_digest_class: OpenSSL::Digest::SHA1
    )
    secret = key_generator.generate_key(config.signed_cookie_salt)
    ActiveSupport::MessageVerifier.new(secret, digest: 'SHA1', serializer: JSON).generate(value)
  end

  def remember_cookie_value
    user.remember_me!
    User.serialize_into_cookie(user)
  end

  it 'keeps the user signed in with the old remember-me cookie' do
    cookies['remember_user_token'] = old_signed_cookie(remember_cookie_value)
    get '/users'
    expect(response).to have_http_status(:ok)
  end

  it 'issues the remember-me cookie again in the new way' do
    cookies['remember_user_token'] = old_signed_cookie(remember_cookie_value)
    get '/users'
    new_value = cookies['remember_user_token'].to_s
    expect(new_value).to be_present
    expect(new_value).not_to eq(old_signed_cookie(remember_cookie_value))
  end

  it 'does not sign in with a cookie signed by another key' do
    forged = ActiveSupport::MessageVerifier.new('x' * 64, digest: 'SHA1', serializer: JSON).generate(remember_cookie_value)
    cookies['remember_user_token'] = forged
    get '/users'
    expect(response).to redirect_to('/users/sign_in')
  end
end
