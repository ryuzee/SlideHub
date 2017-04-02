class ChangeColumnDefaultPassword < ActiveRecord::Migration[4.2]
  def up
    change_column_default :users, :password, ''
    rename_column :users, :created, :created_at
    rename_column :users, :modified, :modified_at
  end
end
