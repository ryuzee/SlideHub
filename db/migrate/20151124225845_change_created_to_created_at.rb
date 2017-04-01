class ChangeCreatedToCreatedAt < ActiveRecord::Migration[4.2]
  def up
    rename_column :slides, :created, :created_at
    rename_column :slides, :modified, :modified_at
  end
end
