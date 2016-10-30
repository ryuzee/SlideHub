# == Schema Information
#
# Table name: categories
#
#  id   :integer          not null, primary key
#  name :string(255)      not null
#

class CategoriesController < ApplicationController
  def show
    @slides = Slide.published.latest.category(params[:id]).includes(:user).
              paginate(page: params[:page], per_page: 20)

    Category.select('name')
    @category = Category.find(params[:id])
  end
end
