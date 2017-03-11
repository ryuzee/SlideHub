source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.0.2'
gem 'rails-controller-testing'

# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.6'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails', '= 4.2.2'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.6.3'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use mysql
gem 'mysql2'

# Use SQLServer
gem 'tiny_tds'
gem 'activerecord-sqlserver-adapter'

# Apply bootstrap
gem 'less-rails'

# WORKAROUND: https://github.com/metaskills/less-rails/issues/122
gem 'sprockets', '3.6.3'

gem 'twitter-bootstrap-rails'
gem 'execjs'

# Paginate
gem 'will_paginate'
gem 'will_paginate-bootstrap'

# Env Var
gem 'dotenv-rails', '= 2.2.0'

# Authentication
gem 'devise', '4.2.0'
gem 'devise-bootstrap-views', '0.0.10'
gem 'devise-i18n', '1.1.1'
gem 'devise-i18n-views', '0.3.7'

# Compatibility with PHP version
# See https://github.com/divoxx/ruby-php-serialization
gem 'php-serialization'

# Add comments
gem 'acts_as_commentable', git: 'https://github.com/ryuzee/acts_as_commentable.git'

# Manage Tags
gem 'acts-as-taggable-on', '~> 4.0'

# Complicated Search
gem 'ransack'

# Manage Title and meta tags
gem 'meta-tags'
gem 'sitemap_generator'

# AWS!!
gem 'aws-sdk', '>= 2.0.0'
gem 'aws-sdk-core'
gem 'aws-sdk-resources'

# Azure
gem 'azure', '~> 0.7.5'
# gem 'azure-contrib', git: 'https://github.com/dmichael/azure-contrib.git'
gem 'azure-contrib', git: 'https://github.com/ryuzee/azure-contrib.git'

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
gem 'momentjs-rails', '~> 2.17.1'
gem 'bootstrap3-datetimepicker-rails', '~> 4.17.47'

# https://github.com/alexspeller/non-stupid-digest-assets
gem 'non-stupid-digest-assets'

# see https://github.com/thoughtbot/paperclip/issues/2021
gem 'paperclip', git: 'https://github.com/thoughtbot/paperclip.git'
gem 'paperclip-azure'

# see http://blog.zeit.io/use-a-fake-db-adapter-to-play-nice-with-rails-assets-precompilation/
# gem 'activerecord-nulldb-adapter'
gem 'activerecord-nulldb-adapter', git: 'https://github.com/mnoack/nulldb.git', ref: 'aa36e3c'

# reserved words for username
gem 'reserved_word'

# dump database
gem 'yaml_db', git: 'https://github.com/dnrce/yaml_db.git', branch: 'bug/109-unquoted-column'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'rspec-rails'
  gem 'factory_girl'
  gem 'factory_girl_rails'
  gem 'simplecov'
  gem 'rspec_junit_formatter'
  gem 'codeclimate-test-reporter'
  gem 'shoulda-matchers', require: false
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 3.4.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # Insert Annotation to files
  gem 'annotate'

  # Static Analysis
  gem 'rubocop', '~> 0.41.1'

  gem 'guard'
  gem 'guard-rubocop'

  gem 'i18n_generators'

  # Find N+1 issue
  gem 'bullet'

  # Visualize Rails Console
  gem 'hirb'
  # gem 'hirb-unicode'

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
  gem 'faker'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'selenium-webdriver'
  gem 'webmock', '~> 1.22.6'
end

group :deployment do
  gem 'capistrano', '~> 3.8.0'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
  gem 'capistrano-bundler'
  gem 'capistrano3-unicorn' # unicornを使っている場合のみ
end
