module Admin
  class UsersController < Admin::BaseController
    before_action :set_user, only: [:edit]

    def index
      ransack_params = params[:q]
      @q = User.search(ransack_params)
      @users = @q.result(distinct: true).
               paginate(page: params[:page], per_page: 20)
    end

    def edit; end

    def update
      params.permit! # It's OK because of admin
      @user = User.find(params[:user][:id])
      @user.assign_attributes(params[:user])
      if @user.update_attributes(params[:user])
        redirect_to admin_users_path
      else
        render :edit
      end
    end

    private

      def set_user
        @user = User.find(params[:id])
      end
  end
end
