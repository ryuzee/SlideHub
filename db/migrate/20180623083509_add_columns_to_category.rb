class AddColumnsToCategory < ActiveRecord::Migration[5.1]
  def up
    add_column :categories, :name_en, :string, null: false, default: ''
    add_column :categories, :name_ja, :string, null: false, default: ''
    execute("UPDATE categories set name_en = name where name_en = ''")
    execute("UPDATE categories set name_ja = name where name_ja = ''")
  end

  def down
    remove_column :categories, :name_en
    remove_column :categories, :name_ja
  end
end
