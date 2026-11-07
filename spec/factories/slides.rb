FactoryBot.define do
  factory :slide, class: Slide do
    name { 'Hoge' }
    description { 'FUGA' }
    sequence(:object_key) { |n| "abcdefg#{n}" }
    extension { '.pdf' }
    convert_status { Slide.convert_statuses[:converted] }
    num_of_pages { 1 }
    sequence(:created_at, 1) { |i| Time.zone.now - i.days }
    downloadable { true }
    tag_list { 'Sushi,Toro' }

    association :user, factory: :default_user
    association :category, factory: :default_category
  end
end
