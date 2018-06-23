class RemoveNameColumnFromCategory < ActiveRecord::Migration[5.1]
  def up
    remove_column :categories, :name
  end
end
