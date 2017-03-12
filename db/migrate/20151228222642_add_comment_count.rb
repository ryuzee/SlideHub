class AddCommentCount < ActiveRecord::Migration[4.2]
  def change
    add_column :slides, :comment_count, :integer, null: false, default: 0
  end
end
