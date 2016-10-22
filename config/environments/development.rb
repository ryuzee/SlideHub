Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => 'public, max-age=172800'
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker

	config.action_mailer.default_url_options = { host: 'localhost:3000' }

  # Bullet
  # See http://ruby-rails.hatenadiary.com/entry/20150204/1423055537
  config.after_initialize do
    Bullet.enable  = true # bullet を有効にする

    # 以下はN+1問題を発見した時のユーザーへの通知方法
    Bullet.alert   = false       # ブラウザのJavaScriptアラート
    Bullet.bullet_logger = true  # Rails.root/log/bullet.log
    Bullet.console = true        # ブラウザの console.log の出力先
    # Bullet.growl   = true      # Growl
    # Bullet.xmpp = { :account  => 'bullets_account@jabber.org',
    #                 :password => 'bullets_password_for_jabber',
    #                 :receiver => 'your_account@jabber.org',
    #                 :show_online_status => true }
    # Bullet.rails_logger = true # Railsのログ
    # Bullet.bugsnag      = true # 総合デバッガツールbugsnag
    # Bullet.airbrake     = true # Airbrake
    Bullet.raise        = false   # Exceptionを発生させる
    Bullet.add_footer   = false   # 画面の下部に表示(ajax時など非同期の場合は表示されない)
    # include paths with any of these substrings in the stack trace,
    # even if they are not in your main app
    # Bullet.stacktrace_includes = [ 'your_gem', 'your_middleware' ]
    Bullet.add_whitelist type: :n_plus_one_query, class_name: 'Slide', association: :tags
    Bullet.add_whitelist type: :n_plus_one_query, class_name: 'Slide', association: :taggings
    Bullet.add_whitelist type: :n_plus_one_query, class_name: 'Slide', association: :tag_taggings
  end

  config.rack_dev_mark.enable = true

  config.web_console.whitelisted_ips = %w(10.0.2.2 192.168.0.0/16 127.0.0.1)
  config.consider_all_requests_local = true
  BetterErrors::Middleware.allow_ip! '10.0.2.2'
  BetterErrors::Middleware.allow_ip! '127.0.0.1'
  BetterErrors::Middleware.allow_ip! '192.168.0.0/16'

  # config.logger = Logger.new(config.paths['log'].first)
  config.logger = ActiveSupport::Logger.new(config.paths['log'].first)
  config.logger.formatter = ::Logger::Formatter.new
end
