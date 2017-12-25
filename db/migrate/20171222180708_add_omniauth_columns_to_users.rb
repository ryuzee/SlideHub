class AddOmniauthColumnsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :provider, :string, null: true
    add_column :users, :uid, :string, null: true
    add_column :users, :token, :string, null: true
  end

  def down
    drop_column :users, :provider
    drop_column :users, :uid
    drop_column :users, :token
  end
end
