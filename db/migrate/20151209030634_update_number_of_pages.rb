class UpdateNumberOfPages < ActiveRecord::Migration
  def up
    Rake::Task['ossjob:update_number_of_pages'].invoke
  end
end
