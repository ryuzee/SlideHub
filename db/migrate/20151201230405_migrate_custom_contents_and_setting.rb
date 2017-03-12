class MigrateCustomContentsAndSetting < ActiveRecord::Migration[4.2]
  def up
    execute('TRUNCATE TABLE settings')

    if ActiveRecord::Base.connection.table_exists?('configs')
      execute("INSERT INTO settings(var, value, thing_id, thing_type) select concat('site.', name),  concat('--- ''', value, ''''), NULL, NULL from configs;")
    end
    if ActiveRecord::Base.connection.table_exists?('custom_contents')
      execute("INSERT INTO settings(var, value, thing_id, thing_type) select concat('custom_content.', name), concat('--- ''',  value,  ''''), NULL, NULL from custom_contents;")
    end
  end
end
