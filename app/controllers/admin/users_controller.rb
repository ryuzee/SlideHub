module Admin
  class UsersController < Admin::BaseController
    before_action :set_user, only: [:edit, :update, :destroy]

    def index
      ransack_params = params[:q]
      @search = User.ransack(ransack_params)
      @users = @search.result(distinct: true).
               paginate(page: params[:page], per_page: 20)
    end

    def edit; end

    def update
      @user.skip_password_validation = true
      @user.assign_attributes(user_params)
      if @user.update_attributes(user_params)
        redirect_to admin_users_path, notice: t(:user_was_updated)
      else
        render :edit
      end
    end

    def destroy
      @user.destroy
      redirect_to admin_users_path
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
