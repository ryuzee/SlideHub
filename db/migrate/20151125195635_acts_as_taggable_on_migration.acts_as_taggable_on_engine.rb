# This migration comes from acts_as_taggable_on_engine (originally 1)
class ActsAsTaggableOnMigration < ActiveRecord::Migration[4.2]
  def self.up
    say_with_time('Create tags') do
      self.create_tags
    end
    say_with_time('Create taggings') do
      self.create_taggings
    end
  end

  def self.create_tags
    return if ActiveRecord::Base.connection.table_exists?('tags')

    create_table :tags do |t|
      t.string :name
    end
  end

  def self.create_taggings
    return if ActiveRecord::Base.connection.table_exists?('taggings')

    create_table :taggings do |t|
      t.references :tag

      # You should make sure that the column created is
      # long enough to store the required class names.
      t.references :taggable, polymorphic: true
      t.references :tagger, polymorphic: true

      # Limit is created to prevent MySQL error on index
      # length for MyISAM table type: http://bit.ly/vgW2Ql
      t.string :context, limit: 128

      t.datetime :created_at
    end
    add_index :taggings, :tag_id
    add_index :taggings, [:taggable_id, :taggable_type, :context]
  end

  def self.down
    drop_table :taggings
    drop_table :tags
  end
end
