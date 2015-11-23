class MigrateOldTagTable < ActiveRecord::Migration
  def up
    execute('INSERT INTO tags(name, taggings_count) select distinct(tags_old.name), count(*) as cnt from tags_old, tagged where tagged.tag_id = tags_old.id group by tags_old.name;')
  end
end
