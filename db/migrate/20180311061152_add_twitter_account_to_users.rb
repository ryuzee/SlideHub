class AddTwitterAccountToUsers < ActiveRecord::Migration[5.1]
  def self.up
    add_column :users, :twitter_account, :string, default: nil, limit: 15
  end

  def self.down
    remove_column :users, :twitter_account
  end
end
