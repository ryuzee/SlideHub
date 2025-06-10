source 'https://rubygems.org'

gem 'json', '~> 2.12'
# gem 'rails', '5.2.7.1'
# gem 'rails', '6.1.7.10'
gem 'rails', '8.0.2'
# Use SCSS for stylesheets
# gem 'sass-rails', '~> 5.0.7'
gem 'sass-rails'
# Use Uglifier as compressor for JavaScript assets
# https://github.com/lautis/uglifier/issues/173#issuecomment-857616825
gem 'uglifier', '= 4.1.0'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'
# Store session to database
gem 'activerecord-session_store'
# Use sqlite3 as the database for Active Record
# gem 'sqlite3'
gem 'sqlite3'

# Use mysql
gem 'execjs'
gem 'mysql2', '~> 0.5'
# gem 'sprockets', '3.7.2'
# Paginate
gem 'will_paginate'
gem 'will_paginate-bootstrap-style'
# Authentication
gem 'devise'
gem 'devise-i18n'
gem 'devise-i18n-views'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-rails_csrf_protection'
gem 'omniauth-saml'
gem 'omniauth-twitter'

# Compatibility with PHP version
# See https://github.com/divoxx/ruby-php-serialization
gem 'php-serialization'
# Manage Tags
gem 'acts-as-taggable-on'

# Complicated Search
gem 'ransack'
# Manage Title and meta tags
gem 'meta-tags'
# AWS
gem 'aws-sdk', '~> 3'
gem 'aws-sdk-s3'
# Azure
gem 'addressable', require: 'addressable/uri'
gem 'azure-storage-blob'
gem 'azure-storage-queue'
gem 'mime-types'
# Find file type
gem 'ruby-filemagic'
# Handle images
gem 'mini_magick'
gem 'rmagick'
# retrieve page count of pdf
gem 'pdf-reader'
# counter cache transaction
gem 'counter_culture'
# AP Server
gem 'momentjs-rails'
gem 'unicorn', '~> 5'
gem 'unicorn-rails'
# https://github.com/alexspeller/non-stupid-digest-assets
# gem 'non-stupid-digest-assets'

# reserved words for username
gem 'reserved_word'
# dump database
gem 'yaml_db'
# i18n for enum
gem 'enum_help'
# Multi Tenant
# gem 'apartment'
gem 'ros-apartment', require: 'apartment'

gem 'psych', '~> 3.1'

gem 'webpacker', '~> 5.0'

# ffi-1.17.0 requires rubygems version >= 3.3.22
# https://github.com/ffi/ffi/issues/1103
gem 'ffi', '1.17.1'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  # gem 'debase'
  gem 'factory_bot'
  gem 'factory_bot_rails'
  gem 'rails-controller-testing'
  gem 'rails-flog', require: 'flog'
  gem 'rspec_junit_formatter'
  gem 'rspec-rails'
  # gem 'ruby-debug-ide'
  gem 'shoulda-matchers', require: false
  gem 'simplecov'
  gem 'simplecov-html'
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
  gem 'meta_request'
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
  gem 'rubocop'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'solargraph'
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
