module Admin
  class SiteSettingsController < Admin::BaseController
    def index
      # 後から追加した設定項目（既存サイトには行が無い）も一覧に出るよう、無い行だけ既定値で作る
      ApplicationSetting.save_default
      @settings = ApplicationSetting.unscoped.where("var like 'site.%'")
    end

    def update
      params.require(:settings).map do |param|
        data = param.to_unsafe_h
        ApplicationSetting[data['var']] = data['value']
      end
      redirect_to '/admin/site_settings/', notice: t(:site_settings_were_saved)
    end
  end
end
