FactoryGirl.define do
  factory :slide, class: Slide do
    user_id 1
    category_id 1
    name 'Hoge'
    description 'FUGA'
    sequence(:key) { |n| "abcdefg#{n}" }
    extension '.pdf'
    convert_status 100
    sequence(:created_at, 1) { |i| Time.now - i.days }

    association :user, factory: :first_user
    association :category, factory: :first_category
  end

  factory :first_user, class: User do
    id 1
    email 'admin02@example.com'
    display_name 'Takashi'
    biography 'Bio'
    password 'password'
    admin true
    initialize_with { User.find_or_create_by(id: id) }
  end

  factory :first_category, class: Category do
    id 1
    name 'Category1'
    initialize_with { Category.find_or_create_by(name: name) }
  end

end
