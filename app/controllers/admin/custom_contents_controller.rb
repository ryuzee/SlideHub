module Admin
  class CustomContentsController < Admin::BaseController
    before_action :clear_cache
    before_action :save_current, only: [:index]
    def index
      @settings = CustomSetting.unscoped.where("var like 'custom_content.%'")
    end

    def update
      params.require(:settings).map do |param|
        data = param.to_unsafe_h
        setting = CustomSetting.find_by(var: data['var']) || CustomSetting.new(var: data['var'])
        setting.value = data['value']
        setting.save
      end
      redirect_to '/admin/custom_contents/', notice: t(:custom_contents_were_saved)
    end

    private

      # :reek:UtilityFunction: { enabled: false }
      def save_current
        keys = %w[custom_content.center_top custom_content.center_bottom custom_content.right_top custom_content.header_menus custom_content.css]
        keys.each do |key|
          setting = CustomSetting.find_by(var: key.to_s) || CustomSetting.new(var: key.to_s)
          setting.value = CustomSetting[key]
          setting.save
        end
      end

      # :reek:UtilityFunction: { enabled: false }
      def clear_cache
        Rails.cache.clear
      end
  end
end
