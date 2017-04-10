module Admin
  class SiteSettingsController < Admin::BaseController
    before_action :save_current, only: [:index]
    def index
      @settings = CustomSetting.unscoped.where("var like 'site.%'")
    end

    def update
      params.require(:settings).map do |param|
        data = param.to_unsafe_h
        CustomSetting[data['var']] = data['value']
        setting = CustomSetting.find_by(var: data['var']) || CustomSetting.new(var: data['var'])
        setting.value = data['value']
        setting.save
      end
      redirect_to '/admin/site_settings/', notice: t(:site_settings_were_saved)
    end

    private

      def save_current
        keys = %w(site.display_login_link site.only_admin_can_upload site.signup_enabled site.name)
        keys.each do |k|
          setting = CustomSetting.find_by(var: k.to_s) || CustomSetting.new(var: k.to_s)
          setting.value = CustomSetting[k]
          setting.save
        end
      end
  end
end
