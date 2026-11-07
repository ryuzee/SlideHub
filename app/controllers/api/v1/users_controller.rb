module Api
  # :reek:UncommunicativeModuleName { enabled: false }
  module V1
    class UsersController < Api::V1::BaseController
      def show
        @user = User.where(id: params[:id]).select('id', 'username', 'display_name', 'biography', 'slides_count').first
        if @user
          render json: JSON.pretty_generate(JSON.parse(@user.to_json))
        else
          not_found
        end
      end
    end
  end
end
