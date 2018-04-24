# == Schema Information
#
# Table name: pages
#
#  id         :bigint(8)        not null, primary key
#  path       :string(30)       not null
#  title      :string(255)      not null
#  content    :text(4294967295)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :default_page, class: Page do
    id 1
    path 'aaa'
    title 'About'
    content 'Contents'
  end
end
