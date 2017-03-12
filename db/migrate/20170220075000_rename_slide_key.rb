class RenameSlideKey < ActiveRecord::Migration[4.2]
  def change
    rename_column :slides, :key, :object_key
  end
end
