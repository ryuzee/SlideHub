module Admin
  class CategoriesController < Admin::BaseController
    before_action :set_category, only: [:edit, :update, :destroy]
    after_action :clear_cache

    def index
      @categories = Category.all.order(:id)
      # カテゴリーごとのスライドの数を、1 回の問い合わせで数える
      @slide_counts = Slide.group(:category_id).count
    end

    def edit; end

    def update
      @category.assign_attributes(category_params)
      if @category.update(category_params)
        redirect_to admin_categories_path, notice: t(:category_was_updated)
      else
        render :edit
      end
    end

    def destroy
      if @category.slides.exists?
        redirect_to admin_categories_path, alert: t(:category_can_not_be_deleted_because_of_existing_slides)
      else
        @category.destroy
        redirect_to admin_categories_path
      end
    end

    def new
      @category = Category.new
    end

    def create
      @category = Category.new(category_params)
      if @category.save
        redirect_to admin_categories_path, notice: t(:category_was_created)
      else
        render :new
      end
    end

    private

      def set_category
        @category = Category.find(params[:id])
      end

      def category_params
        params.require(:category).permit(:name_en, :name_ja)
      end

      def clear_cache
        Rails.cache.clear
      end
  end
end
