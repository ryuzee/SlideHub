FactoryBot.define do
  factory :default_page, class: Page do
    path { 'aaa' }
    title { 'About' }
    content { 'Contents' }
  end
end
