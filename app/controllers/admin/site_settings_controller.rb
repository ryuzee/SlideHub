module Admin
  class SiteSettingsController < Admin::BaseController
    def index
      @settings = CustomSetting.unscoped.where("var like 'site.%'")
    end

    def update
      params.require(:settings).map do |param|
        data = param.to_unsafe_h
        CustomSetting[data['var']] = data['value']
      end
      redirect_to '/admin/site_settings/'
    end
  end
end
