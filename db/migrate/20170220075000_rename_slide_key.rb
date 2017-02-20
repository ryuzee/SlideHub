class RenameSlideKey < ActiveRecord::Migration
  def change
    rename_column :slides, :key, :object_key
  end
end
