class UpdatedAt < ActiveRecord::Migration[5.1]
  def self.up
    rename_column :slides, :modified_at, :updated_at
    rename_column :users, :modified_at, :updated_at
    rename_column :comments, :modified_at, :updated_at
    add_column :categories, :created_at, :datetime, default: nil
    add_column :categories, :updated_at, :datetime, default: nil
  end

  def self.down
    rename_column :slides, :updated_at, :modified_at
    rename_column :users, :updated_at, :modified_at
    rename_column :comments, :updated_at, :modified_at
    remove_column :categories, :created_at
    remove_column :categories, :updated_at
  end
end
