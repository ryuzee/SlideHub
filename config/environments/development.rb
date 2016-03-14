Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  # config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  config.action_mailer.default_url_options = { host: 'localhost:3000' }

  # Bullet
  # See http://ruby-rails.hatenadiary.com/entry/20150204/1423055537
  config.after_initialize do
    Bullet.enable  = true # bullet を有効にする

    # 以下はN+1問題を発見した時のユーザーへの通知方法
    Bullet.alert   = true        # ブラウザのJavaScriptアラート
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
    Bullet.raise        = true   # Exceptionを発生させる
    Bullet.add_footer   = true   # 画面の下部に表示(ajax時など非同期の場合は表示されない)
    # include paths with any of these substrings in the stack trace,
    # even if they are not in your main app
    # Bullet.stacktrace_includes = [ 'your_gem', 'your_middleware' ]
    Bullet.add_whitelist type: :n_plus_one_query, class_name: 'Slide', association: :tag
    Bullet.add_whitelist type: :n_plus_one_query, class_name: 'Slide', association: :tagging
  end

  config.rack_dev_mark.enable = true

  config.web_console.whitelisted_ips = '10.0.2.2'
  config.consider_all_requests_local = true
  BetterErrors::Middleware.allow_ip! '10.0.2.2'
end
