class AddUniqueToKeyOnSlides < ActiveRecord::Migration[4.2]
  def up
    add_index :slides, :key, unique: true
  end
end
