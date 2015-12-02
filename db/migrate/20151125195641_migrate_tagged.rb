class MigrateTagged < ActiveRecord::Migration
  def up
    if ActiveRecord::Base.connection.table_exists?('tagged') && ActiveRecord::Base.connection.table_exists?('cakephp_tags_old')
      execute("INSERT INTO taggings(tag_id, taggable_id, taggable_type, tagger_id, tagger_type, context, created_at) select tags.id, tagged.foreign_key, 'Slide', NULL, NULL, 'tags', now() from tagged, cakephp_tags_old, tags where cakephp_tags_old.name = tags.name and tagged.tag_id = cakephp_tags_old.id;")
    end
  end
end
