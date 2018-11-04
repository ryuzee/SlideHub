class AddAvatarsToUsers < ActiveRecord::Migration[4.2]
  def self.up
    change_table :users do |t|
      t.binary :avatar
    end
  end

  def self.down
    remove_column :users, :avatar
  end
end
