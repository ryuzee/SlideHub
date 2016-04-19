# == Schema Information
#
# Table name: slides
#
#  id             :integer          not null, primary key
#  user_id        :integer          not null
#  name           :string(255)      not null
#  description    :text(65535)      not null
#  downloadable   :boolean          default(FALSE), not null
#  category_id    :integer          not null
#  created_at     :datetime         not null
#  modified_at    :datetime
#  key            :string(255)      default("")
#  extension      :string(10)       default(""), not null
#  convert_status :integer          default(0)
#  total_view     :integer          default(0), not null
#  page_view      :integer          default(0)
#  download_count :integer          default(0), not null
#  embedded_view  :integer          default(0), not null
#  num_of_pages   :integer          default(0)
#  comments_count :integer          default(0), not null
#

FactoryGirl.define do
  factory :slide, class: Slide do
    user_id 1
    category_id 1
    name 'Hoge'
    description 'FUGA'
    sequence(:key) { |n| "abcdefg#{n}" }
    extension '.pdf'
    convert_status 100
    num_of_pages 1
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
