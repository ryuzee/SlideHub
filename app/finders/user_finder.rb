class UserFinder
  def initialize; end

  def self.username_to_id(username)
    User.find_by(username: username).id
  end

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

  # auth.extra.raw_info
  # In Keycloak, you need to set Mapper as follows (All items must be User Property)
  # Property   Attribute
  # ---------------------
  # email      email
  # firstName  first_name
  # lastName   last_name
  # username   username
  #
  def self.find_for_saml_oauth(auth)
    user = User.find_by(provider: auth.provider, uid: auth.uid)
    user ||= User.create(username: auth.extra.raw_info['username'],
                         display_name: auth.extra.raw_info['last_name'] + ' ' + auth.extra.raw_info['first_name'],
                         biography: '',
                         provider: auth.provider,
                         uid: auth.uid,
                         email: auth.info.email,
                         twitter_account: '',
                         password: Devise.friendly_token[0, 20])
    user
  end
end
