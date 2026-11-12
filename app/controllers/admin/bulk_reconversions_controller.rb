module Admin
  class BulkReconversionsController < Admin::BaseController
    # 一括再変換のおおよその進捗（サイト設定画面が数秒おきに取得する）
    def show
      progress = BulkReconversionProgress.new
      progress.remember_finish
      render json: progress
    end

    def create
      # 前のサムネイル一括再生成が終わっていれば、キューが増える前に終わったと記録しておく
      ThumbnailRegenerationProgress.new.remember_finish
      count = BulkReconversionService.new.request_all
      BulkReconversionProgress.record(count)
      redirect_to '/admin/site_settings/', notice: t(:bulk_reconversion_requested, count: count)
    end
  end
end
