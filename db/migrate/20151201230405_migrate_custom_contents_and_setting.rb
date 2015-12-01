class MigrateCustomContentsAndSetting < ActiveRecord::Migration
  def up
    execute("TRUNCATE TABLE settings")
    execute("INSERT INTO settings(var, value, thing_id, thing_type) select concat('site.', name),  concat('--- ''', value, ''''), NULL, NULL from configs;")
    execute("INSERT INTO settings(var, value, thing_id, thing_type) select concat('custom_content.', name), concat('--- ''',  value,  ''''), NULL, NULL from custom_contents;")
  end
end
