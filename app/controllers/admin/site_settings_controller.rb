module Admin
  class SiteSettingsController < Admin::BaseController
    def index
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
