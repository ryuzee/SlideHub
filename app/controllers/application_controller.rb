class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include OriginCheckLogging

  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_category_data
  before_action :set_uploadable
  before_action :signup_enabled?, if: :devise_controller?
  before_action :set_host
  before_action :set_default_meta_tags
  before_action :authenticate_user! if Rails.application.config.slidehub.login_required == '1'

  include ActsAsTaggableOn::TagsHelper

  private

    # :reek:FeatureEnvy { enabled: false }
    def set_locale
      require Rails.root.join('lib', 'slide_hub', 'locale_util')
      I18n.locale = SlideHub::LocaleUtil.locale(request)
      # 同じ URL でも、ブラウザの言語設定で日本語と英語の画面を出し分けている。
      # 手前の CDN などが、違う言語の画面をキャッシュから返さないよう伝える
      response.headers['Vary'] = 'Accept-Language'
    end

    # 一覧のページ番号が範囲外（スライドのある最後のページより後ろ）なら 404 にする。
    # 空のページを返すと、検索エンジンに中身のない重複ページとして扱われる。
    # 1 ページ目は、スライドが 0 件でも表示する
    def ensure_page_in_range(collection)
      return if collection.current_page <= 1 || collection.current_page <= collection.total_pages

      raise ActionController::RoutingError, 'Not Found'
    end

    # 公開画面のカテゴリの一覧（ヘッダーのメニュー、トップページ、カテゴリのページ）
    def set_category_data
      @categories = Category.with_published_slides.order('id asc')
    end

    def set_uploadable
      @uploadable = user_signed_in?
      @uploadable = false if user_signed_in? && !current_user.admin && ApplicationSetting['site.only_admin_can_upload'] == '1'
    end

    # サインアップが無効なときは、登録の画面表示と送信をどちらも 404 にする（HTTP メソッドに関係なく）
    def signup_enabled?
      return if ApplicationSetting['site.signup_enabled'] == '1'
      return unless controller_name == 'registrations' && %w[new create].include?(action_name)

      raise ActionController::RoutingError, 'Not Found'
    end

    # TODO: move to specific controller??
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up,        keys: [:display_name, :biography, :avatar, :username, :twitter_account])
      devise_parameter_sanitizer.permit(:account_update, keys: [:display_name, :biography, :avatar, :username, :twitter_account])
    end

    def set_host
      if Rails.env.production?
        Rails.application.routes.default_url_options[:host] = request.host_with_port || Rails.application.config.slidehub.root_url
      end
    end

    # サイト共通のOGP/Twitter Cardの既定値。各ビューでset_meta_tagsすれば上書きされる
    def set_default_meta_tags
      site_name = ApplicationSetting['site.name']
      set_meta_tags og: {
        site_name: site_name,
        locale: I18n.locale.to_s == 'ja' ? 'ja_JP' : 'en_US',
        type: 'website',
      }, twitter: {
        card: 'summary',
      }
    end
end
