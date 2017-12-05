class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_category_data
  before_action :set_uploadable
  before_action :signup_enabled!, if: :devise_controller?

  include ActsAsTaggableOn::TagsHelper

  private

    def set_locale
      locale = locale_from_accept_language
      I18n.locale = (I18n.available_locales.include?(locale.to_sym) ? locale.to_sym : I18n.default_locale)
    end

    def locale_from_accept_language
      if request.env.key?('HTTP_ACCEPT_LANGUAGE')
        request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
      else
        I18n.default_locale
      end
    end

    def set_category_data
      @categories = Category.order('id asc')
    end

    def set_uploadable
      @uploadable = user_signed_in?
      @uploadable = false if user_signed_in? && !current_user.admin && CustomSetting['site.only_admin_can_upload'] == '1'
    end

    def signup_enabled!
      return unless request.get?
      if request.path == '/users/sign_up' && CustomSetting['site.signup_enabled'] != '1'
        raise ActionController::RoutingError, 'Not Found'
      end
    end

    def configure_permitted_parameters
      actions = [:sign_up, :account_update]
      actions.each do |a|
        devise_parameter_sanitizer.permit(a, keys: [:display_name, :biography, :avatar, :username])
      end
    end
end
