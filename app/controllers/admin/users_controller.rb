module Admin
  class UsersController < Admin::BaseController
    def index
      ransack_params = params[:q]
      @q = User.search(ransack_params)
      @users = @q.result(distinct: true).
        paginate(page: params[:page], per_page: 20)
    end
  end
end
