module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    # See https://github.com/heartcombo/devise/issues/3119
    skip_before_action :verify_authenticity_token, only: :saml

    def facebook
      @user = UserFinder.find_for_facebook_oauth(request.env['omniauth.auth'])

      if @user.persisted?
        set_flash_message(:notice, :success, kind: 'Facebook') if is_navigational_format?
        sign_in_and_redirect @user, event: :authentication # this will throw if @user is not activated
      else
        session['devise.user_attributes'] = @user.attributes
        redirect_to new_user_registration_url
      end
    end

    def twitter
      @user = UserFinder.find_for_twitter_oauth(request.env['omniauth.auth'])

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
  end
end
