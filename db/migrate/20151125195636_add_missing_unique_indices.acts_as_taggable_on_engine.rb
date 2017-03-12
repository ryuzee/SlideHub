# This migration comes from acts_as_taggable_on_engine (originally 2)
class AddMissingUniqueIndices < ActiveRecord::Migration[4.2]
  def self.up
    unless ActiveRecord::Base.connection.index_exists?(:tags, [:name], name: 'index_tags_on_name')
      add_index :tags, :name, unique: true
    end

    if ActiveRecord::Base.connection.index_exists?(:taggings, [:tag_id], name: 'index_taggings_on_tag_id')
      remove_index :taggings, :tag_id
    end

    if ActiveRecord::Base.connection.index_exists?(:taggings, [:taggable_id, :taggable_type, :context], name: 'index_taggings_on_taggable_id_and_taggable_type_and_context')
      remove_index :taggings, [:taggable_id, :taggable_type, :context]
    end

    unless ActiveRecord::Base.connection.index_exists?(:taggings, [:tag_id, :taggable_id, :taggable_type, :context, :tagger_id, :tagger_type], name: 'taggings_idx')
      add_index :taggings,
                [:tag_id, :taggable_id, :taggable_type, :context, :tagger_id, :tagger_type],
                unique: true, name: 'taggings_idx'
    end
  end

  def self.down
    remove_index :tags, :name

    remove_index :taggings, name: 'taggings_idx'
    add_index :taggings, :tag_id
    add_index :taggings, [:taggable_id, :taggable_type, :context]
  end
end
