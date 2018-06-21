class AddInitialSettingData < ActiveRecord::Migration[5.1]
  def up
    ApplicationSetting.save_default
  end
end
