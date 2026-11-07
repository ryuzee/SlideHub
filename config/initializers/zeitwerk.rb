ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym 'IO'
end

# lib/slide_hub/version.rb は、慣習どおり定数 SlideHub::VERSION を定義する
Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect('version' => 'VERSION')
end
