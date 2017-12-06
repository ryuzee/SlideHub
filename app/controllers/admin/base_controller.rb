module Admin
  class BaseController < ApplicationController
    layout 'admin'
    before_action :authenticate_user!
    before_action :admin?

    private

      def admin?
        if !user_signed_in? || !current_user.admin
          redirect_to new_user_session_path
        end
      end
  end
end
