# you can run `bundle exec rails runner 'Rails.cache.clear'` to clear cache
if ActiveRecord::Base.connection.table_exists?('settings')
  CustomSetting.save_default('site.display_login_link', '1')
  CustomSetting.save_default('site.only_admin_can_upload', '0')
  CustomSetting.save_default('site.signup_enabled', '1')
  CustomSetting.save_default('site.name', 'SlideHub')
  CustomSetting.save_default('custom_content.center_top', '')
  CustomSetting.save_default('custom_content.center_bottom', '')
  CustomSetting.save_default('custom_content.right_top', '')
end
