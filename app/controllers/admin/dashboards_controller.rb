module Admin
  class DashboardsController < Admin::BaseController
    def index
      @dashboard = Dashboard.new
    end
  end
end
