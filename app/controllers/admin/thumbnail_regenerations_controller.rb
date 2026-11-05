module Admin
  class ThumbnailRegenerationsController < Admin::BaseController
    def create
      count = ThumbnailRegenerationService.new.request_all
      redirect_to '/admin/site_settings/', notice: t(:regenerate_thumbnails_requested, count: count)
    end
  end
end
