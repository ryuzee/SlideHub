class CreateFeaturedSlides < ActiveRecord::Migration[5.0]
  def change
    create_table :featured_slides do |t|
      t.integer  'slide_id', limit: 4, null: false
      t.timestamps
    end
    add_index :featured_slides, ['slide_id'], name: 'idx_featured_slides_ukey', unique: true, using: :btree
  end
end
