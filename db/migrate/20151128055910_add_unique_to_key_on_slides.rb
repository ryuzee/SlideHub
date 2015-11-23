class AddUniqueToKeyOnSlides < ActiveRecord::Migration
  def up
    add_index :slides, :key, unique: true
  end
end
