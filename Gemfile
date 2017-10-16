source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.1.4'

# See https://qiita.com/shinichinomura/items/41e03d7e4fa56841e654
gem 'json', '~> 1.8.6'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.6'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '~> 3.2.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', '~> 0.12.3', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails', '= 4.3.1'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use mysql
gem 'mysql2'

# Use SQLServer
# gem 'activerecord-sqlserver-adapter', '~> 5.1.1'
# See https://github.com/rails-sqlserver/activerecord-sqlserver-adapter/issues/613
gem 'activerecord-sqlserver-adapter', git: 'https://github.com/rails-sqlserver/activerecord-sqlserver-adapter.git'
gem 'tiny_tds'

# Apply bootstrap
# gem 'less-rails'
# See https://qiita.com/Jey/items/f69e93755be8ec959124
gem 'less-rails', git: 'https://github.com/MustafaZain/less-rails.git'

# WORKAROUND: https://github.com/metaskills/less-rails/issues/122
gem 'sprockets', '3.7.1'

gem 'execjs'
gem 'twitter-bootstrap-rails'

# Paginate
gem 'will_paginate'
gem 'will_paginate-bootstrap'

# Authentication
gem 'devise', '4.3.0'
gem 'devise-bootstrap-views', '0.0.11'
gem 'devise-i18n', '1.3.0'
gem 'devise-i18n-views', '0.3.7'

# Compatibility with PHP version
# See https://github.com/divoxx/ruby-php-serialization
gem 'php-serialization'

# Manage Tags
# https://github.com/mbleigh/acts-as-taggable-on/issues/808
gem 'acts-as-taggable-on', git: 'https://github.com/mbleigh/acts-as-taggable-on.git'

# Complicated Search
gem 'ransack'

# Manage Title and meta tags
gem 'meta-tags'
gem 'sitemap_generator'

# AWS!!
gem 'aws-sdk', '~> 2.6'
gem 'aws-sdk-core'
gem 'aws-sdk-resources'

# Azure
gem 'azure', '~> 0.7.5'
# gem 'azure-contrib', git: 'https://github.com/dmichael/azure-contrib.git'
gem 'azure-contrib', git: 'https://github.com/ryuzee/azure-contrib.git', ref: 'b74076c'

# Find file type
gem 'ruby-filemagic'

# Handle images
gem 'rmagick'

# retrieve page count of pdf
gem 'pdf-reader'

# counter cache transaction
gem 'counter_culture'

# save settings
gem 'rails-settings-cached', '0.6.5'

# AP Server
gem 'unicorn'

# Datetime Picker for Bootstrap3
gem 'bootstrap3-datetimepicker-rails', '~> 4.17.47'
gem 'momentjs-rails', '~> 2.17.1'

# https://github.com/alexspeller/non-stupid-digest-assets
gem 'non-stupid-digest-assets'

# Upload images to Cloud
gem 'paperclip'
gem 'paperclip-azure'

# see http://blog.zeit.io/use-a-fake-db-adapter-to-play-nice-with-rails-assets-precompilation/
gem 'activerecord-nulldb-adapter'

# reserved words for username
gem 'reserved_word'

# dump database
gem 'yaml_db', '~> 0.6.0'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'codeclimate-test-reporter'
  gem 'factory_girl'
  gem 'factory_girl_rails'
  gem 'rspec-rails'
  gem 'rspec_junit_formatter'
  gem 'rails-controller-testing'
  gem 'shoulda-matchers', require: false
  gem 'simplecov'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # Insert Annotation to files
  gem 'annotate'

  # Static Analysis
  gem 'rubocop', '~> 0.49.1'

  gem 'guard'
  gem 'guard-rubocop'

  gem 'i18n_generators'

  # Find N+1 issue
  gem 'bullet'

  # Visualize Rails Console
  gem 'hirb'

  # Generate ER
  gem 'rails-erd'

  # Display the environment name
  # https://github.com/dtaniwaki/rack-dev-mark
  gem 'rack-dev-mark'

  # Include template path
  gem 'view_source_map'

  # Display nice error screen
  gem 'better_errors'
  gem 'binding_of_caller'

  # Finding code smell
  gem 'reek'

  # Rails Best Practice
  gem 'rails_best_practices'

  # Brakeman
  gem 'brakeman', require: false
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'faker'
  gem 'launchy'
  gem 'selenium-webdriver'
  gem 'webmock'
end
