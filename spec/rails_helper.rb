# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] = 'test'
ENV['OSS_USE_AZURE'] ||= '0'
ENV['OSS_TWITTER_CONSUMER_KEY'] ||= 'dummy'
ENV['OSS_TWITTER_CONSUMER_SECRET'] ||= 'dummy'
ENV['OSS_FACEBOOK_APP_ID'] ||= 'dummy'
ENV['OSS_FACEBOOK_APP_SECRET'] ||= 'dummy'
ENV['OSS_LOGIN_REQUIRED'] = '0'

require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
  #
  config.include FactoryBot::Syntax::Methods

  # deviseのテストヘルパーをロードする
  Rails.application.reload_routes_unless_loaded
  require 'devise'
  require 'support/controller_macros'
  require 'support/omniauth_macros'
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view
  config.include ControllerMacros, type: :controller

  require 'support/cloud_helpers'

  # DatabaseCleaner
  require 'database_cleaner'
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :active_record
    with.library :active_model
    with.library :action_controller
    with.library :rails
  end
end

# In factory_bot 5, associations default to using the same build strategy as their parent object
# See https://qiita.com/TunaGinger/items/ca08b1eaa5c1e321e302
FactoryBot.use_parent_strategy = false

require 'capybara/rails'

Capybara.server = :webrick
Capybara.app = Rails.application
Capybara.server_host = '127.0.0.1'
Capybara.app_host = 'http://127.0.0.1:3001'
Capybara.server_port = 3001
Capybara.default_max_wait_time = 10
Capybara.default_driver = :rack_test
Capybara.current_driver = :rack_test
