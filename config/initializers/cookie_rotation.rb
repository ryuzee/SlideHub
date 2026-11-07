# Rails 7.0 から、Cookie の署名や暗号化に使う鍵を作る方式が SHA1 から SHA256 に変わった（load_defaults 7.0 以降）。
# 切り替える前に発行した Cookie（「ログインしたままにする」の Cookie など）もそのまま読めるよう、
# 古い方式の鍵でも確かめる。読めた Cookie は、次に書き込むときに新しい方式で発行し直される。
#
# 「ログインしたままにする」の Cookie の期限（Devise の remember_for、初期値 2 週間）が過ぎたら外してよい
Rails.application.config.after_initialize do
  Rails.application.config.action_dispatch.cookies_rotations.tap do |cookies|
    config = Rails.application.config.action_dispatch
    key_generator = ActiveSupport::KeyGenerator.new(
      Rails.application.secret_key_base, iterations: 1000, hash_digest_class: OpenSSL::Digest::SHA1
    )

    cookies.rotate :signed, key_generator.generate_key(config.signed_cookie_salt)
    cookies.rotate :encrypted, key_generator.generate_key(config.authenticated_encrypted_cookie_salt,
                                                          ActiveSupport::MessageEncryptor.key_len)
  end
end
