# ブラウザ（Chrome）を使うテストの設定。js: true を付けた system spec だけがブラウザを使う。
#
# - SELENIUM_REMOTE_URL があるとき（開発環境の docker compose）：chrome コンテナの Chrome を使う。
#   Chrome からアプリに届くよう、テスト用のサーバーはすべてのアドレスで待ち受け、
#   このコンテナのホスト名で呼んでもらう。Chrome が動いていなければ、理由を出してテストを飛ばす
# - ないとき（CI）：同じマシンの Chrome をヘッドレスで使う
require 'socket'
require 'net/http'

module BrowserTest
  SERVER_PORT = 3011

  def self.remote_url
    ENV.fetch('SELENIUM_REMOTE_URL', nil).presence
  end

  def self.remote_available?
    return @remote_available if defined?(@remote_available)

    uri = URI.join(remote_url, '/status')
    @remote_available = Net::HTTP.get_response(uri).is_a?(Net::HTTPSuccess)
  rescue StandardError
    @remote_available = false
  end

  # テストで開くアプリの origin。後片付けで localStorage を消すのに使う（chrome_reset.rb）。
  # 後片付けの前に Capybara.app_host が戻されることがあるので、ここに覚えておく
  def self.app_origin
    @app_origin || Capybara.current_session.server&.base_url
  end

  def self.app_origin=(origin)
    @app_origin = origin
  end

  def self.chrome_arguments
    %w[--headless=new --no-sandbox --disable-dev-shm-usage --window-size=1280,900]
  end
end

RSpec.configure do |config|
  # テストのコードから Chrome（WebDriver）へは通信してよい。終わりの後片付け（画面の保存や
  # ブラウザを閉じる）でも通信するので、テストの間ずっと許しておく
  config.before(:suite) do
    WebMock.disable_net_connect!(allow_localhost: true, allow: URI(BrowserTest.remote_url).host) if BrowserTest.remote_url
  end

  config.before(type: :system, js: true) do
    if BrowserTest.remote_url
      unless BrowserTest.remote_available?
        skip "Chrome is not running. Start it with: docker compose --profile test up -d chrome (#{BrowserTest.remote_url})"
      end

      Capybara.server_host = '0.0.0.0'
      Capybara.server_port = BrowserTest::SERVER_PORT
      Capybara.app_host = "http://#{Socket.gethostname}:#{BrowserTest::SERVER_PORT}"
      BrowserTest.app_origin = Capybara.app_host
      driven_by :selenium, using: :headless_chrome, screen_size: [1280, 900],
                           options: { browser: :remote, url: BrowserTest.remote_url }
    else
      driven_by :selenium, using: :headless_chrome, screen_size: [1280, 900] do |options|
        BrowserTest.chrome_arguments.each { |argument| options.add_argument(argument) }
      end
    end
  end

  config.after(type: :system, js: true) do
    Capybara.app_host = nil
    Capybara.server_host = nil
  end
end
