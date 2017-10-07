# == Schema Information
#
# Table name: categories
#
#  id   :integer          not null, primary key
#  name :string(255)      not null
#

FactoryGirl.define do
  factory :default_category, class: Category do
    id 1
    name 'Category1'
    initialize_with { Category.find_or_create_by(name: name) }
  end
end
