class UserFinder
  def initialize; end

  def self.find_for_facebook_oauth(auth)
    user = User.find_by(provider: auth.provider, uid: auth.uid)
    user ||= User.create(username: auth.extra.raw_info.username,
                         display_name: auth.extra.raw_info.name,
                         biography: '',
                         provider: auth.provider,
                         uid: auth.uid,
                         email: auth.info.email,
                         token: auth.credentials.token,
                         twitter_account: '',
                         password: Devise.friendly_token[0, 20])
    user
  end

  def self.find_for_twitter_oauth(auth)
    user = User.find_by(provider: auth.provider, uid: auth.uid)
    user ||= User.create(username: auth.info.nickname,
                         display_name: auth.info.name,
                         biography: auth.info.description,
                         provider: auth.provider,
                         uid: auth.uid,
                         email: '',
                         twitter_account: auth.info.nickname,
                         password: Devise.friendly_token[0, 20])
    user
  end
end
