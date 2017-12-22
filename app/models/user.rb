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

class User < ApplicationRecord
  attr_accessor :skip_password_validation
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable
  self.table_name = 'users'
  validates :display_name, presence: true
  validates :display_name, length: { maximum: 32 }
  validates :biography, presence: true
  validates :biography, length: { maximum: 1024 }
  validates :username, uniqueness: true, length: { minimum: 3, maximum: 32 }
  VALID_USERNAME_REGEX = /\A[a-zA-Z][0-9A-Za-z\-_]{1,30}[a-zA-Z0-9]\z/
  validates :username, format: { with: VALID_USERNAME_REGEX }, exclusion: { in: ReservedWord.list }
  has_many :slides

  has_attached_file :avatar, styles: { medium: '192x192>', thumb: '100x100#' }, default_url: 'avatar/:style/missing.png'
  validates_attachment_content_type :avatar, content_type: %r{\Aimage/.*\Z}

  def password_required?
    return false if skip_password_validation
    # super && provider.blank?
    provider.blank?
  end

  def update_with_password(params, *options)
    if !password_required?
      update_attributes(params, *options)
    else
      super
    end
  end

  def self.username_to_id(username)
    User.where('username = ?', username).first.id
  end

  def self.new_with_session(params, session)
    if session['devise.user_attributes']
      new(session['devise.user_attributes']) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end

  def self.find_for_facebook_oauth(auth)
    user = User.where(provider: auth.provider, uid: auth.uid).first

    unless user
      user = User.create(username:     auth.extra.raw_info.username,
                         display_name: auth.extra.raw_info.name,
                         biography: '',
                         provider: auth.provider,
                         uid:      auth.uid,
                         email:    auth.info.email,
                         token:    auth.credentials.token,
                         password: Devise.friendly_token[0, 20])
    end
    user
  end

  def self.find_for_twitter_oauth(auth)
    user = User.where(provider: auth.provider, uid: auth.uid).first
    unless user
      user = User.create(username:     auth.info.nickname,
                         display_name: auth.info.name,
                         biography: auth.info.description,
                         provider: auth.provider,
                         uid:      auth.uid,
                         email:    '',
                         password: Devise.friendly_token[0, 20])
    end
    user
  end
end
