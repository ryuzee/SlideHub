class AddSessionsTable < ActiveRecord::Migration[5.1]
  def change
    create_table :sessions do |table|
      table.string :session_id, null: false
      table.text :data
      table.timestamps
    end

    add_index :sessions, :session_id, unique: true
    add_index :sessions, :updated_at
  end
end
