class RemoveUniqueConstraintFromUsers < ActiveRecord::Migration[5.1]
  def up
    remove_index :users, :reset_password_token if ActiveRecord::Base.connection_config[:adapter] == 'sqlserver'
  end

  def down
    add_index :users, :reset_password_token, unique: true if ActiveRecord::Base.connection_config[:adapter] == 'sqlserver'
  end
end
