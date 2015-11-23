class ChangeColumnDefaultPassword < ActiveRecord::Migration
  def up
    change_column_default :users, :password, ''
    rename_column :users, :created, :created_at
    rename_column :users, :modified, :modified_at
  end

  def down
  end
end
