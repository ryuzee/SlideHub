class ChangeCreatedToCreatedAt < ActiveRecord::Migration
  def up
    rename_column :slides, :created, :created_at
    rename_column :slides, :modified, :modified_at
  end

  def down
  end
end
