class UpdateNumberOfPages < ActiveRecord::Migration[4.2]
  def up
    Rake::Task['slidehub:update_number_of_pages'].invoke
  end
end
