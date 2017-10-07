class DropCommentableFields < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :comments, :commentable_type
    remove_column :comments, :role
    rename_column :comments, :commentable_id, :slide_id
  end

  def self.down
    add_column :comments, :commentable_type, :string, default: 'Slide'
    add_column :comments, :role, :string, default: 'comments'
    rename_column :comments, :slide_id, :commentable_id
  end
end
