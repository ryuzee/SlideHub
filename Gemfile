source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails', '= 4.0.5'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# readline
gem 'rb-readline'

# Use mysql
gem 'mysql2'

# Apply bootstrap
gem 'less-rails'
gem 'twitter-bootstrap-rails', '= 3.2.0'
gem 'execjs'

# Paginate
gem 'will_paginate'
gem 'will_paginate-bootstrap'

# Env Var
gem 'dotenv-rails'

# Authentication
gem 'devise'
gem 'devise-bootstrap-views'
gem 'devise-i18n'
gem 'devise-i18n-views'

# Compatibility with PHP version
# See https://github.com/divoxx/ruby-php-serialization
gem 'php-serialization'

# Add comments
gem 'acts_as_commentable'

# Manage Tags
gem 'acts-as-taggable-on'

# Complicated Search
gem 'ransack'

# Manage Title and meta tags
gem 'meta-tags'
gem 'sitemap_generator'

# AWS!!
gem 'aws-sdk', '>= 2.0.0'
gem 'aws-sdk-core'
gem 'aws-sdk-resources'

# Find file type
gem 'ruby-filemagic'

# Handle images
gem 'rmagick'

# retrieve page count of pdf
gem 'pdf-reader'

# counter cache transaction
gem 'counter_culture'

# save settings
gem 'rails-settings-cached', '= 0.4.4'

# AP Server
gem 'unicorn'

# Datetime Picker for Bootstrap3
gem 'momentjs-rails', '>= 2.9.0'
gem 'bootstrap3-datetimepicker-rails', '~> 4.17.37'

gem 'packr', git: 'https://github.com/ryuzee/packr'

# https://github.com/alexspeller/non-stupid-digest-assets
gem 'non-stupid-digest-assets'

# see https://github.com/thoughtbot/paperclip/issues/2021
gem 'paperclip', :git => 'https://github.com/thoughtbot/paperclip.git'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'rspec-rails'
  gem 'factory_girl'
  gem 'factory_girl_rails'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # Insert Annotation to files
  gem 'annotate'

  # Static Analysis
  gem 'rubocop'

  gem 'guard'
  gem 'guard-rubocop'

  gem 'i18n_generators'

  # Find N+1 issue
  gem 'bullet'

  # Visualize Rails Console
  gem 'hirb'
  gem 'hirb-unicode'

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
end

group :test do
  gem 'faker'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'selenium-webdriver'
end

group :deployment do
  gem 'capistrano', '~> 3.2.1'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
  gem 'capistrano-bundler'
  gem 'capistrano3-unicorn' # unicornを使っている場合のみ
end
