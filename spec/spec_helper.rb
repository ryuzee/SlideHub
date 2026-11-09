require 'simplecov'
require 'webmock/rspec'
require 'shoulda/matchers'
require 'omniauth'

# 本物のサービスには通信しない（必要な通信は stub_request で用意する）
WebMock.disable_net_connect!(allow_localhost: true)

SimpleCov.start do
  skip '/vendor/'
  skip '/spec/'

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

  # テストは毎回ランダムな順で流す。順番に頼るテストがあれば、すぐ分かるようにするため。
  # 落ちたときは、出力の「Randomized with seed」の値を --seed に渡すと同じ順で再現できる
  config.order = :random
  Kernel.srand config.seed
end

OmniAuth.config.test_mode = true

require 'support/session_helpers'

RSpec.configure do |config|
  config.include SessionHelpers, type: :system
end
