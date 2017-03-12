class DeleteConfigAndCustomContents < ActiveRecord::Migration[4.2]
  def up
    drop_table 'configs' if ActiveRecord::Base.connection.table_exists?('configs')
    drop_table 'custom_contents' if ActiveRecord::Base.connection.table_exists?('custom_contents')
  end
end
