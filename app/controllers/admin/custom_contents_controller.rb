class Admin::CustomContentsController < Admin::ApplicationController
  def index
    @settings = CustomSetting.unscoped.where("var like 'custom_content.%'")
  end

  def update
    params.require(:settings).map do |param|
      data = param.to_unsafe_h
      CustomSetting[data['var']] = data['value']
    end
    redirect_to '/admin/custom_contents/'
  end
end
