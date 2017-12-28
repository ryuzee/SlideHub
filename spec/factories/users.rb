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
#

FactoryBot.define do
  factory :default_user, class: User do
    id 1
    email 'user01@example.com'
    display_name 'User01'
    biography 'Bio'
    password 'password'
    admin false
    username 'user01'
    reset_password_token 'user01'
    initialize_with { User.find_or_create_by(id: id) }
  end

  factory :another_user, class: User do
    id 998
    email 'general998@example.com'
    display_name 'Yoshi'
    biography 'Bio'
    password 'password'
    admin false
    username 'general998'
    reset_password_token 'general998'
    initialize_with { User.find_or_create_by(id: id) }
  end

  factory :admin_user, class: User do
    id 999
    email 'admin999@example.com'
    display_name 'Takashi'
    biography 'Bio'
    password 'password'
    admin true
    username 'admin999'
    reset_password_token 'admin999'
    initialize_with { User.find_or_create_by(id: id) }
  end
end
