class AddColumnsToComments < ActiveRecord::Migration[4.2]
  def up
    rename_column :comments, :slide_id, :commentable_id
    rename_column :comments, :content, :comment
    rename_column :comments, :created, :created_at
    rename_column :comments, :modified, :modified_at
    add_column :comments, :commentable_type, :string, default: 'Slide'
    add_column :comments, :role, :string, default: 'comments'

    add_index :comments, :commentable_id
    add_index :comments, :commentable_type
    add_index :comments, :user_id
  end

  def down
  end
end
