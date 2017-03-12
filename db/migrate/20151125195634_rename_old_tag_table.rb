class RenameOldTagTable < ActiveRecord::Migration[4.2]
  def up
    rename_table :tags, :cakephp_tags_old if ActiveRecord::Base.connection.table_exists?(:tags)
  end

  def down
  end
end
