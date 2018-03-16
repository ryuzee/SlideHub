class RemoveColumnFromSettings < ActiveRecord::Migration[5.1]
  def change
    remove_index :settings, name: 'index_settings_on_thing_type_and_thing_id_and_var'
    remove_column :settings, :thing_id
    remove_column :settings, :thing_type
    add_index :settings, ['var'], name: 'idx_settings_key', using: :btree
  end
end
