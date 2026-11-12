module Admin
  class BulkReconversionsController < Admin::BaseController
    def create
      count = BulkReconversionService.new.request_all
      redirect_to '/admin/site_settings/', notice: t(:bulk_reconversion_requested, count: count)
    end
  end
end
