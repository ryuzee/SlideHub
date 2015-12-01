class DeleteCakephpSchemaMigrations < ActiveRecord::Migration
  def change
    if ActiveRecord::Base.connection.table_exists?('cakephp_schema_migrations')
      drop_table 'cakephp_schema_migrations'
    end
  end
end
