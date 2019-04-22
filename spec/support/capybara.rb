def take_screenshot
  unless ENV.key?('CIRCLECI')
    page.save_screenshot Rails.root.join('tmp', 'capybara', "screenshot-#{DateTime.now.in_time_zone.strftime('%Y%m%d%H%M%S')}.png")
  end
end

return if ENV.key?('CIRCLECI')

Capybara.server = :webrick, { Silent: true }

Capybara.default_driver = :chrome_headless

Capybara.register_driver :chrome_headless do |app|
  options = ::Selenium::WebDriver::Chrome::Options.new

  options.add_argument('--user-data-dir=/tmp/profile')
  options.add_argument('--headless')
  options.add_argument('--no-sandbox')
  # see https://discuss.circleci.com/t/selenium-says-chrome-is-unreachable-works-fine-locally/29335
  # options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--window-size=1400,1400')

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.javascript_driver = :chrome_headless

# Setup rspec
RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do
    driven_by :chrome_headless
  end
end
