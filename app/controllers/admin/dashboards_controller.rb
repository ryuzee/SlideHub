module Admin
  class DashboardsController < Admin::BaseController
    def show
      @dashboard = Dashboard.new
    end
  end
end
