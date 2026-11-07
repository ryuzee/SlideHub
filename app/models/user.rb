# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  admin                  :boolean          default(FALSE), not null
#  avatar                 :binary(65535)
#  biography              :text(65535)
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string(255)
#  disabled               :boolean          default(FALSE)
#  display_name           :string(128)      not null
#  email                  :string(32)       not null
#  encrypted_password     :string(255)      default(""), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string(255)
#  password               :string(255)      default(""), not null
#  provider               :string(255)
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string(255)
#  sign_in_count          :integer          default(0), not null
#  slides_count           :integer          default(0)
#  token                  :string(255)
#  twitter_account        :string(15)
#  uid                    :string(255)
#  username               :string(255)      not null
#  created_at             :datetime         not null
#  updated_at             :datetime
#
class User < ApplicationRecord
  attr_accessor :skip_password_validation, :current_password

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable, omniauth_providers: [:twitter, :facebook, :saml]
  self.table_name = 'users'
  validates :display_name, presence: true
  validates :display_name, length: { maximum: 32 }
  validates :biography, presence: true
  validates :biography, length: { maximum: 1024 }

  VALID_USERNAME_REGEX = /\A[a-zA-Z][0-9A-Za-z\-_]{1,30}[a-zA-Z0-9]\z/
  validates :username, uniqueness: true,
                       length: { minimum: 3, maximum: 32 },
                       format: { with: VALID_USERNAME_REGEX },
                       exclusion: { in: ReservedWord.list }

  # current twitter account length must be greater than 5...
  VALID_TWITTER_ACCOUNT_REGEX = /\A[a-zA-Z][0-9A-Za-z\-_]{1,15}[a-zA-Z0-9]\z/
  validates :twitter_account, allow_blank: true,
                              length: { minimum: 1, maximum: 15 },
                              format: { with: VALID_TWITTER_ACCOUNT_REGEX }

  has_many :slides, dependent: :destroy
  has_one_attached :avatar
  attribute :admin, :boolean, default: false
  attribute :disabled, :boolean, default: false

  # 検索・並べ替えに使ってよい項目。管理画面（auth_object が :admin）では一覧の項目すべて、
  # それ以外（公開の検索でスライドの投稿者を探すとき）は名前だけにする
  ADMIN_RANSACKABLE_ATTRIBUTES = %w[
    display_name username email provider admin disabled slides_count
    sign_in_count last_sign_in_at created_at
  ].freeze
  PUBLIC_RANSACKABLE_ATTRIBUTES = %w[display_name username].freeze

  def self.ransackable_attributes(auth_object = nil)
    auth_object == :admin ? ADMIN_RANSACKABLE_ATTRIBUTES : PUBLIC_RANSACKABLE_ATTRIBUTES
  end

  # 投稿者から先の関連（スライドなど）では検索しない
  def self.ransackable_associations(_auth_object = nil)
    []
  end

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
