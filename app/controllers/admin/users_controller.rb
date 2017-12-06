module Admin
  class UsersController < Admin::BaseController
    before_action :set_user, only: [:edit]

    def index
      ransack_params = params[:q]
      @search = User.search(ransack_params)
      @users = @search.result(distinct: true).
               paginate(page: params[:page], per_page: 20)
    end

    def edit; end

    def update
      @user = User.find(params[:user][:id])
      @user.assign_attributes(user_params)
      if @user.update_attributes(user_params)
        redirect_to admin_users_path
      else
        render :edit
      end
    end

    private

      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        params.require(:user).permit(:id, :username, :display_name, :email, :biography, :admin)
      end
  end
end
