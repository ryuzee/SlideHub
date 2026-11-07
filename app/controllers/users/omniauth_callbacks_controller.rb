module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    # See https://github.com/heartcombo/devise/issues/3119
    skip_before_action :verify_authenticity_token, only: :saml
    # SAML の応答は IdP のサイトから送られてくるので、Origin が違って当然（ログに残さない）
    skip_before_action :log_origin_mismatch, only: :saml

    def facebook
      @user = UserFinder.find_for_facebook_oauth(request.env['omniauth.auth'], create: signup_allowed?)
      return redirect_unregistered_account if @user.nil?

      if @user.persisted?
        set_flash_message(:notice, :success, kind: 'Facebook') if is_navigational_format?
        sign_in_and_redirect @user, event: :authentication # this will throw if @user is not activated
      else
        session['devise.user_attributes'] = @user.attributes
        redirect_to new_user_registration_url
      end
    end

    def twitter
      @user = UserFinder.find_for_twitter_oauth(request.env['omniauth.auth'], create: signup_allowed?)
      return redirect_unregistered_account if @user.nil?

      if @user.persisted?
        set_flash_message(:notice, :success, kind: 'Twitter') if is_navigational_format?
        sign_in_and_redirect @user, event: :authentication
      else
        session['devise.user_attributes'] = @user.attributes
        redirect_to new_user_registration_url
      end
    end

    def saml
      @user = UserFinder.find_for_saml_oauth(request.env['omniauth.auth'])

      if @user.persisted?
        set_flash_message(:notice, :success, kind: 'SAML') if is_navigational_format?
        sign_in_and_redirect @user, event: :authentication
      else
        session['devise.user_attributes'] = @user.attributes
        redirect_to new_user_registration_url
      end
    end

    private

      # サインアップが無効なときは、まだ登録していない人のアカウントを作らない（X・Facebook）。
      # SAML はこの判定をしないが、初回は自己紹介が空のため作成に失敗し、サインアップ画面に送られる。
      # そのため SAML でも、サインアップが無効なら新しい人は登録できない
      def signup_allowed?
        ApplicationSetting['site.signup_enabled'] == '1'
      end

      def redirect_unregistered_account
        redirect_to new_user_session_path, alert: t(:account_not_registered)
      end
  end
end
