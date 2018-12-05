source 'https://rubygems.org'

gem 'rails', '5.2.1.1'
gem 'json', '~> 1.8'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.7'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '~> 4.1'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', '~> 0.12.3', platforms: :ruby
# Use jquery as the JavaScript library
gem 'jquery-rails', '~> 4.3.3'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.8.0'
# Store session to database
gem 'activerecord-session_store'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use mysql
gem 'mysql2', '~> 0.5'

# Commented out because gem for rails 5.2 is not released yet...
# Use SQLServer
# gem 'activerecord-sqlserver-adapter'
gem 'activerecord-sqlserver-adapter', git: 'https://github.com/matthewdunbar/activerecord-sqlserver-adapter.git'
# gem 'tiny_tds'

# Apply bootstrap
# gem 'less-rails'
# See https://github.com/metaskills/less-rails/issues/122
# See https://qiita.com/Jey/items/f69e93755be8ec959124
# twitter-bootstrap-rails depends on less-rails ~> 2.8. However this issue was resolved in 3.0...
gem 'less-rails', git: 'https://github.com/MustafaZain/less-rails.git'
gem 'sprockets', '3.7.2'
gem 'execjs'
gem 'twitter-bootstrap-rails', '~> 4.0'
# Paginate
gem 'will_paginate'
gem 'bootstrap-will_paginate'
# Authentication
gem 'devise', '4.5.0'
gem 'devise-bootstrap-views', '0.0.11'
gem 'devise-i18n', '~> 1.6'
gem 'devise-i18n-views', '0.3.7'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-twitter'

# Compatibility with PHP version
# See https://github.com/divoxx/ruby-php-serialization
gem 'php-serialization'
# Manage Tags
# https://github.com/mbleigh/acts-as-taggable-on/issues/808
# gem 'acts-as-taggable-on', git: 'https://github.com/Fodoj/acts-as-taggable-on', branch: 'rails-5.2'
gem 'acts-as-taggable-on', git: 'https://github.com/mbleigh/acts-as-taggable-on.git'

# Complicated Search
gem 'ransack'
# Manage Title and meta tags
gem 'meta-tags'
gem 'sitemap_generator'
# AWS
gem 'aws-sdk', '~> 3'
gem 'aws-sdk-s3'
# Azure
gem 'azure'
gem 'azure-storage'
# Find file type
gem 'ruby-filemagic'
# Handle images
gem 'rmagick'
gem 'mini_magick'
# retrieve page count of pdf
gem 'pdf-reader'
# counter cache transaction
gem 'counter_culture'
# AP Server
gem 'unicorn'
# Datetime Picker for Bootstrap3
gem 'bootstrap3-datetimepicker-rails', '~> 4.17.47'
gem 'momentjs-rails'
# https://github.com/alexspeller/non-stupid-digest-assets
gem 'non-stupid-digest-assets'

# reserved words for username
gem 'reserved_word'
# dump database
gem 'yaml_db'
# i18n for enum
gem 'enum_help'
# Multi Tenant
gem 'apartment'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'debase'
  gem 'factory_bot'
  gem 'factory_bot_rails'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'rspec_junit_formatter'
  gem 'ruby-debug-ide'
  gem 'shoulda-matchers', require: false
  gem 'simplecov'
end

group :development do
  # Insert Annotation to files
  gem 'annotate'
  # Display nice error screen
  gem 'better_errors'
  gem 'binding_of_caller'
  # Brakeman
  gem 'brakeman', require: false
  # Find N+1 issue
  gem 'bullet'
  gem 'guard'
  gem 'guard-rubocop'
  # Visualize Rails Console
  gem 'hirb'
  gem 'i18n_generators'
  # Display the environment name
  # https://github.com/dtaniwaki/rack-dev-mark
  gem 'rack-dev-mark'
  # Rails Best Practice
  gem 'rails_best_practices'
  # Generate ER
  gem 'rails-erd'
  # Finding code smell
  gem 'reek'
  # Static Analysis
  gem 'rubocop', '~> 0.61'
  gem 'rubocop-rspec'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  # Include template path
  gem 'view_source_map'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'faker'
  gem 'launchy'
  gem 'selenium-webdriver'
  gem 'webmock'
end

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end
