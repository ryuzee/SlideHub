class AddCommentCount < ActiveRecord::Migration
  def change
    add_column :slides, :comment_count, :integer, null: false, default: 0
  end
end
