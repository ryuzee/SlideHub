module Admin
  class CustomContentsController < Admin::BaseController
    def index
      @settings = ApplicationSetting.unscoped.where("var like 'custom_content.%'")
    end

    def update
      params.require(:settings).map do |param|
        data = param.to_unsafe_h
        ApplicationSetting[data['var']] = data['value']
      end
      redirect_to '/admin/custom_contents/', notice: t(:custom_contents_were_saved)
    end
  end
end
