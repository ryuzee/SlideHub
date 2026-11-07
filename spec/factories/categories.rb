FactoryBot.define do
  factory :default_category, class: Category do
    name_en { 'Category1' }
    name_ja { 'Category1_ja' }
    initialize_with { Category.find_or_create_by(name_en: name_en) }
  end
end
