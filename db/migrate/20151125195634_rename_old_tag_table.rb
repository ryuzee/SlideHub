class RenameOldTagTable < ActiveRecord::Migration
  def up
    rename_table :tags, :tags_old
  end

  def down
  end
end
