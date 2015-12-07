FactoryGirl.define do
  factory :user_admin, class: User do
    id 1
    email 'admin02@example.com'
    display_name 'Takashi'
    biography 'Bio'
    password 'password'
    admin true
  end
end
