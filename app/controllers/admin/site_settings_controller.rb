module Admin
  class SiteSettingsController < Admin::BaseController
    def index
      # 後から追加した設定項目（既存サイトには行が無い）も一覧に出るよう、無い行だけ既定値で作る
      ApplicationSetting.save_default
      @settings = ApplicationSetting.unscoped.where("var like 'site.%'")
      @reconversion_target_count = BulkReconversionService.targets.count
    end

    def update
      # 画面からは settings[番号][var] の形（スイッチの hidden と checkbox を同じ設定にまとめるため）、
      # 以前の形式 settings[][var] は配列で届く
      settings = params.require(:settings)
      settings = settings.values if settings.is_a?(ActionController::Parameters)
      settings.each do |param|
        data = param.to_unsafe_h
        ApplicationSetting[data['var']] = data['value']
      end
      redirect_to '/admin/site_settings/', notice: t(:site_settings_were_saved)
    end
  end
end
