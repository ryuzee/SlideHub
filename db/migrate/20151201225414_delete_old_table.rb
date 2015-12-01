class DeleteOldTable < ActiveRecord::Migration
  def up
    drop_table "tagged"
    drop_table "cake_sessions"
    drop_table "cakephp_tags_old"
  end
end
