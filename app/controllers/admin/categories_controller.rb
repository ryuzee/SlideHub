module Admin
  class CategoriesController < Admin::BaseController
    before_action :set_category, only: [:edit, :update, :destroy]

    def index
      @categories = Category.all.order(:id).includes(:slides)
    end

    def edit; end

    def update
      @category.assign_attributes(category_params)
      if @category.update_attributes(category_params)
        redirect_to admin_categories_path, notice: t(:category_was_updated)
      else
        render :edit
      end
    end

    def destroy
      if @category.slides.count > 0
        redirect_to admin_categories_path, notice: t(:category_can_not_be_deleted_because_of_existing_slides)
      else
        @category.destroy
        redirect_to admin_categories_path
      end
    end

    private

      def set_category
        @category = Category.includes(:slides).find(params[:id])
      end

      def category_params
        params.require(:category).permit(:id, :name_en, :name_ja)
      end
  end
end
