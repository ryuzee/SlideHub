class RenameCommentCount < ActiveRecord::Migration
  def change
    rename_column :slides, :comment_count, :comments_count
  end
end
