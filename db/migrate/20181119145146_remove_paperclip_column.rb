class RemovePaperclipColumn < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :avatar_file_name if column_exists? :users, :avatar_file_name
    remove_column :users, :avatar_content_type if column_exists? :users, :avatar_content_type
    remove_column :users, :avatar_file_size if column_exists? :users, :avatar_file_size
    remove_column :users, :avatar_updated_at if column_exists? :users, :avatar_updated_at
  end
end
