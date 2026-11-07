FactoryBot.define do
  factory :featured_slide do
    slide { FactoryBot.create :slide }
  end
end
