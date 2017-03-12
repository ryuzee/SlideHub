class ChangeColumnDefaultEmail < ActiveRecord::Migration[4.2]
  def change
    change_column_default :users, :email, nil
  end
end
