class RenameCommentCount < ActiveRecord::Migration[4.2]
  def change
    rename_column :slides, :comment_count, :comments_count
  end
end
