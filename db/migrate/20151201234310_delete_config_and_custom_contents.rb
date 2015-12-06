class DeleteConfigAndCustomContents < ActiveRecord::Migration
  def up
    drop_table 'configs' if ActiveRecord::Base.connection.table_exists?('configs')
    drop_table 'custom_contents' if ActiveRecord::Base.connection.table_exists?('custom_contents')
  end
end
