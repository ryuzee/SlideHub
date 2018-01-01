class AddPages < ActiveRecord::Migration[5.1]
  def self.up
    create_table :pages do |table|
      table.string  :path, limit: 30, null: false
      table.string  :title, limit: 255, null: false
      table.text :content, limit: 4_294_967_295
      table.timestamps null: false
    end
    add_index :pages, ['path'], name: 'idx_pages_ukey', unique: true, using: :btree
  end

  def self.down
    drop_table 'pages'
  end
end
