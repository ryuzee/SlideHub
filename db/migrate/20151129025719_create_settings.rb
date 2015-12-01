class CreateSettings < ActiveRecord::Migration
  def self.up
    unless ActiveRecord::Base.connection.table_exists?('settings')
      create_table :settings do |t|
        t.string  :var,        null: false
        t.text    :value,      null: true
        t.integer :thing_id,   null: true
        t.string  :thing_type, null: true, limit: 30
        t.timestamps
      end

      add_index :settings, %i(thing_type thing_id var), unique: true
    end
  end

  def self.down
    drop_table :settings
  end
end
