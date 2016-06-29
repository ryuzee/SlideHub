class UpdateNumberOfPages < ActiveRecord::Migration
  def up
    Rake::Task['slidehub:update_number_of_pages'].invoke
  end
end
