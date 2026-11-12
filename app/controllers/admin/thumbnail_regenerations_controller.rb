module Admin
  class ThumbnailRegenerationsController < Admin::BaseController
    # 一括再生成のおおよその進捗（サイト設定画面が数秒おきに取得する）
    def show
      progress = ThumbnailRegenerationProgress.new
      progress.remember_finish
      render json: progress
    end

    def create
      # 前の一括再変換が終わっていれば、キューが増える前に終わったと記録しておく
      BulkReconversionProgress.new.remember_finish
      count = ThumbnailRegenerationService.new.request_all
      ThumbnailRegenerationProgress.record(count)
      redirect_to '/admin/site_settings/', notice: t(:regenerate_thumbnails_requested, count: count)
    end
  end
end
