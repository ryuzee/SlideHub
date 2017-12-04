FactoryBot.define do
  factory :default_custom_file, class: Category do
    id 1
    path 'dummy.txt'
    description 'description1'
    initialize_with { CustomFile.find_or_create_by(path: path) }
  end
end
