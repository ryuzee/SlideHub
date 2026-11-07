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
      # 自分自身の管理者は外せない（管理者がいなくなり、誰も管理画面に入れなくなるのを防ぐ）
      keep_own_admin = @user == current_user && !@user.admin
      @user.admin = true if keep_own_admin
      if @user.save
        notice = keep_own_admin ? t(:cannot_remove_own_admin) : t(:user_was_updated)
        redirect_to admin_users_path, notice: notice
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
        params.require(:user).permit(:username, :display_name, :email, :biography, :admin)
      end
  end
end
