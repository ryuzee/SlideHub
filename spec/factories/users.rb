FactoryBot.define do
  factory :default_user, class: User do
    email { 'user01@example.com' }
    display_name { 'User01' }
    biography { 'Bio' }
    password { 'password' }
    admin { false }
    username { 'user01' }
    reset_password_token { 'user01' }
    initialize_with { User.find_or_create_by(email: email) }
  end

  factory :another_user, class: User do
    email { 'general998@example.com' }
    display_name { 'Yoshi' }
    biography { 'Bio' }
    password { 'password' }
    admin { false }
    username { 'general998' }
    reset_password_token { 'general998' }
    initialize_with { User.find_or_create_by(email: email) }
  end

  factory :admin_user, class: User do
    email { 'admin999@example.com' }
    display_name { 'Takashi' }
    biography { 'Bio' }
    password { 'password' }
    admin { true }
    username { 'admin999' }
    reset_password_token { 'admin999' }
    initialize_with { User.find_or_create_by(email: email) }
  end
end
