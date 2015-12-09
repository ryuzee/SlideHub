class AddNumOfPagesToSlides < ActiveRecord::Migration
  def up
    add_column :slides, :num_of_pages, :integer, default: 0
  end
end
