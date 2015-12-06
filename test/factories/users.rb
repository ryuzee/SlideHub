FactoryGirl.define do
  factory :admin, class: User do
    id 3
    email 'admin02@example.com'
    display_name 'Takashi'
    biography 'Bio'
    password 'password'
    admin true
  end
end
