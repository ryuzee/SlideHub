# Capybara 3.40 は、テストのあとの後片付けで、Chrome にすべてのサイトの Cookie と
# localStorage を消させる。そのとき origin に '*' を渡しているが、Chrome 158 からは
# 正しい URL でないと受け付けなくなり、ブラウザを使うテストが後片付けで失敗する。
# そこで同じことを、Cookie はブラウザ全体から、localStorage はテストで開くアプリの
# origin から消す形に置き換える。Capybara がこの呼び出しを直したら、このファイルは消してよい
module ChromeResetWithoutWildcard
  def execute_cdp(command, **params)
    return super unless command == 'Storage.clearDataForOrigin' && params[:origin] == '*'

    super('Network.clearBrowserCookies')
    storage_types = params[:storageTypes].to_s.split(',') - ['cookies']
    return if storage_types.empty?

    origin = BrowserTest.app_origin
    super('Storage.clearDataForOrigin', origin: origin, storageTypes: storage_types.join(',')) if origin
  end
end

require 'capybara/selenium/driver'

Capybara::Selenium::Driver::ChromeDriver.prepend(ChromeResetWithoutWildcard)
