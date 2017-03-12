class DeleteCakephpSchemaMigrations < ActiveRecord::Migration[4.2]
  def change
    if ActiveRecord::Base.connection.table_exists?('cakephp_schema_migrations')
      drop_table 'cakephp_schema_migrations'
    end
  end
end
