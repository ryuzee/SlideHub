FactoryBot.define do
  factory :comment_for_slide, class: Comment do
    association :user, factory: :another_user, strategy: :build
    slide { FactoryBot.create :slide }
    comment { 'Sushi' }
  end
end
