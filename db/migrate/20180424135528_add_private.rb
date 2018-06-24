class AddPrivate < ActiveRecord::Migration[5.1]
  def up
    add_column :slides, :private, :boolean, null: false, default: false
  end

  def down
    remove_column :slides, :private
  end
end
