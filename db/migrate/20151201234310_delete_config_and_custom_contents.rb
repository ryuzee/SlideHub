class DeleteConfigAndCustomContents < ActiveRecord::Migration
  def up
    drop_table "configs"
    drop_table "custom_contents"
  end
end
