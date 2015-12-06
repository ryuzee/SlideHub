class DeleteOldTable < ActiveRecord::Migration
  def up
    drop_table 'tagged' if ActiveRecord::Base.connection.table_exists?('tagged')
    drop_table 'cake_sessions' if ActiveRecord::Base.connection.table_exists?('cake_sessions')
    drop_table 'cakephp_tags_old' if ActiveRecord::Base.connection.table_exists?('cakephp_tags_old')
  end
end
