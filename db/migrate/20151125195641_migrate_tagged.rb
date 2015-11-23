class MigrateTagged < ActiveRecord::Migration
  def up
    execute("INSERT INTO taggings(tag_id, taggable_id, taggable_type, tagger_id, tagger_type, context, created_at) select tags.id, tagged.foreign_key, 'Slide', NULL, NULL, 'tags', now() from tagged, tags_old, tags where tags_old.name = tags.name and tagged.tag_id = tags_old.id;")
  end
end

