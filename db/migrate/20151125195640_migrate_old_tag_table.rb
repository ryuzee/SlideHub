class MigrateOldTagTable < ActiveRecord::Migration
  def up
    execute('INSERT INTO tags(name, taggings_count) select distinct(cakephp_tags_old.name), count(*) as cnt from cakephp_tags_old, tagged where tagged.tag_id = cakephp_tags_old.id group by cakephp_tags_old.name;')
  end
end
