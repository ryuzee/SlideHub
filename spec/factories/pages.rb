FactoryBot.define do
  factory :default_page, class: Page do
    id 1
    path 'aaa'
    title 'About'
    content 'Contents'
  end
end
