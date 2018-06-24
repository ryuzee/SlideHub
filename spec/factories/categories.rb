# == Schema Information
#
# Table name: categories
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#

FactoryBot.define do
  factory :default_category, class: Category do
    id 1
    name_en 'Category1'
    name_ja 'Category1_ja'
    initialize_with { Category.find_or_create_by(name_en: name_en) }
  end
end
