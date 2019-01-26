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
#  updated_at             :datetime
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
#  provider               :string(255)
#  uid                    :string(255)
#  token                  :string(255)
#  twitter_account        :string(15)
#

class User < ApplicationRecord
  attr_accessor :skip_password_validation
  attr_accessor :current_password
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable
  self.table_name = 'users'
  validates :display_name, presence: true
  validates :display_name, length: { maximum: 32 }
  validates :biography, presence: true
  validates :biography, length: { maximum: 1024 }

  VALID_USERNAME_REGEX = /\A[a-zA-Z][0-9A-Za-z\-_]{1,30}[a-zA-Z0-9]\z/.freeze
  validates :username, uniqueness: true,
                       length: { minimum: 3, maximum: 32 },
                       format: { with: VALID_USERNAME_REGEX },
                       exclusion: { in: ReservedWord.list }

  # current twitter account length must be greater than 5...
  VALID_TWITTER_ACCOUNT_REGEX = /\A[a-zA-Z][0-9A-Za-z\-_]{1,15}[a-zA-Z0-9]\z/.freeze
  validates :twitter_account, allow_nil: true,
                              allow_blank: true,
                              length: { minimum: 1, maximum: 15 },
                              format: { with: VALID_TWITTER_ACCOUNT_REGEX }

  has_many :slides, dependent: :destroy
  has_one_attached :avatar

  def password_required?
    return false if skip_password_validation
    return false if provider.present?

    super
  end

  def update_with_password(params, *options)
    avatar.attach(params[:avatar]) if params.key?(:avatar)
    super
  end

  def update_without_password(params, *options)
    avatar.attach(params[:avatar]) if params.key?(:avatar)
    super
  end

  def self.username_to_id(username)
    User.find_by(username: username).id
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
end
