module Admin
  class ThumbnailRegenerationsController < Admin::BaseController
    # 一括再生成のおおよその進捗（サイト設定画面が数秒おきに取得する）
    def show
      render json: ThumbnailRegenerationProgress.new
    end

    def create
      count = ThumbnailRegenerationService.new.request_all
      ThumbnailRegenerationProgress.record(count)
      redirect_to '/admin/site_settings/', notice: t(:regenerate_thumbnails_requested, count: count)
    end
  end
end
