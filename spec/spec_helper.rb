require 'simplecov'
require 'webmock/rspec'
require 'shoulda/matchers'
require 'omniauth'

WebMock.allow_net_connect!

# save to CircleCI's artifacts directory if we're on CircleCI
if ENV['CIRCLE_ARTIFACTS']
  dir = File.join(ENV.fetch('CIRCLE_ARTIFACTS', nil), 'coverage')
  SimpleCov.coverage_dir(dir)
end

SimpleCov.start do
  add_filter '/vendor/'
  add_filter '/spec/'

  SimpleCov.formatters = [
    SimpleCov::Formatter::HTMLFormatter,
  ]
end

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end

OmniAuth.config.test_mode = true

require 'support/session_helpers'

RSpec.configure do |config|
  config.include SessionHelpers, type: :feature
end
