require_relative 'boot'
require_relative '../lib/slide_hub/env_util'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SlideHub
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1
    config.autoloader = :zeitwerk
    # Active Storage の画像の変換（variant）は使わない（アバターは元の画像をそのまま出す）
    config.active_storage.variant_processor = :disabled

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = SlideHub::EnvUtil.fetch('TIMEZONE', 'Asia/Tokyo')

    # The default locale is :ja (Accept-Language が無い・未対応の場合). All translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :ja

    # config.autoload_paths += %W[#{config.root}/lib]
    # config.autoload_paths += %W[#{config.root}/lib/slide_hub]
    config.autoload_paths << "#{config.root}/lib"
    config.eager_load_paths << "#{config.root}/lib"
    # config.autoload_paths << "#{config.root}/lib/slide_hub"

    # JS/CSS は jsbundling-rails / cssbundling-rails (esbuild) で app/assets/builds に出力し、propshaft で配信する
    config.public_file_server.enabled

    config.enable_dependency_loading = true
    # config.active_record.sqlite3.represent_boolean_as_integer = true

    # Do not swallow errors in after_commit/after_rollback callbacks.
    # config.active_record.raise_in_transactional_callbacks = true

    config.generators do |generator|
      generator.test_framework :rspec,
                               fixtures: true,
                               view_specs: false,
                               helper_specs: false,
                               routing_specs: false,
                               controller_specs: true,
                               request_specs: false
      generator.fixture_replacement :factory_bot, dir: 'spec/factories'
    end

    # すべての応答に付けるヘッダー（いまの Rails の標準と同じ）。
    # ほかのサイトに枠で表示してよいのは埋め込み用のプレイヤー（HtmlPlayerController）だけ、
    # ほかのサイトから読んでよいのは API と埋め込み用の JavaScript だけで、それぞれのコントローラーで変える
    config.action_dispatch.default_headers = {
      'X-Frame-Options' => 'SAMEORIGIN',
      'X-XSS-Protection' => '0',
      'X-Content-Type-Options' => 'nosniff',
      'X-Permitted-Cross-Domain-Policies' => 'none',
      'Referrer-Policy' => 'strict-origin-when-cross-origin',
    }
  end
end
