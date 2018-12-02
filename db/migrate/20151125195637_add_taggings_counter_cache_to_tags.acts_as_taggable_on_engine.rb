# This migration comes from acts_as_taggable_on_engine (originally 3)
class AddTaggingsCounterCacheToTags < ActiveRecord::Migration[4.2]
  def self.up
    add_column :tags, :taggings_count, :integer, default: 0

    say_with_time('Reset column information') do
      ActsAsTaggableOn::Tag.reset_column_information
    end
    say_with_time('Reset counters') do
      ActsAsTaggableOn::Tag.find_each do |tag|
        ActsAsTaggableOn::Tag.reset_counters(tag.id, :taggings)
      end
    end
  end

  def self.down
    remove_column :tags, :taggings_count
  end
end
