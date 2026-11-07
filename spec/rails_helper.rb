# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] = 'test'

# アプリが環境変数から読む設定は、テストでは決まった値にする。
# 開発環境のコンテナの値（本物のバケット名や CDN の URL など）が入ると、
# 人や CI によって結果が変わり、本物のサービスに通信してしまうため
{
  'USE_AZURE' => '0',
  'USE_S3_STATIC_HOSTING' => '0',
  'MULTI_TENANT' => '0',
  'MULTI_TENANT_EXCLUDED_SUBDOMAINS' => '',
  'TIMEZONE' => 'Asia/Tokyo',
  'AWS_ACCESS_ID' => 'test-access-id',
  'AWS_SECRET_KEY' => 'test-secret-key',
  'REGION' => 'ap-northeast-1',
  'BUCKET_NAME' => 'test-bucket',
  'IMAGE_BUCKET_NAME' => 'test-image-bucket',
  'CDN_BASE_URL' => '',
  'SQS_URL' => 'https://sqs.ap-northeast-1.amazonaws.com/000000000000/test-queue',
  'AZURE_CDN_BASE_URL' => '',
  'AZURE_CONTAINER_NAME' => 'test-container',
  'AZURE_IMAGE_CONTAINER_NAME' => 'test-image-container',
  'AZURE_QUEUE_NAME' => 'test-queue',
  'AZURE_STORAGE_ACCESS_KEY' => 'dGVzdA==',
  'AZURE_STORAGE_ACCOUNT_NAME' => 'testaccount',
  'FACEBOOK_APP_ID' => 'dummy',
  'FACEBOOK_APP_SECRET' => 'dummy',
  'TWITTER_CONSUMER_KEY' => 'dummy',
  'TWITTER_CONSUMER_SECRET' => 'dummy',
  'TWITTER_CALLBACK_URL' => 'http://test.host/users/auth/twitter/callback',
  'IDP_CERT_FINGERPRINT' => '',
  'IDP_SSO_TARGET_URL' => '',
  'FROM_EMAIL' => 'test@example.com',
  'SMTP_SERVER' => '',
  'SMTP_PORT' => '',
  'SMTP_AUTH_METHOD' => '',
  'SMTP_USERNAME' => '',
  'SMTP_PASSWORD' => '',
  'ROOT_URL' => 'http://test.host',
  'LOGIN_REQUIRED' => '0',
}.each do |key, value|
  ENV.delete("SLIDEHUB_#{key}")
  ENV["OSS_#{key}"] = value
end

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
  config.fixture_paths = ["#{::Rails.root}/spec/fixtures"]

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
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include ControllerMacros, type: :controller

  require 'support/cloud_helpers'
  require 'support/cloud_isolation'

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

# 画面の操作を確かめるテスト（spec/system）は、ブラウザを使わずアプリを直接呼ぶ rack_test で動かす。
# JavaScript を動かすテストを足すときは、そのテストだけ別のドライバーにする
Capybara.default_max_wait_time = 10
RSpec.configure do |config|
  config.before(type: :system) do
    driven_by :rack_test
  end
end
