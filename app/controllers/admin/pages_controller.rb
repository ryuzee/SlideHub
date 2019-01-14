module Admin
  class PagesController < Admin::BaseController
    before_action :set_page, only: [:edit, :update, :destroy]

    def index
      ransack_params = params[:q]
      @search = Page.ransack(ransack_params)
      @pages = @search.result(distinct: true).
               paginate(page: params[:page], per_page: 20)
    end

    def new
      @page = Page.new
    end

    def create
      @page = Page.new(page_params)
      if @page.save
        redirect_to admin_pages_path, notice: t(:page_was_created)
      else
        render :new
      end
    end

    def edit; end

    def update
      if @page.update(page_params)
        redirect_to admin_pages_path, notice: t(:page_was_updated)
      else
        render 'edit'
      end
    end

    def destroy
      @page.destroy
      redirect_to admin_pages_path, notice: t(:page_was_deleted)
    end

    private

      def set_page
        @page = Page.find(params[:id])
      end

      def page_params
        params.require(:page).permit(:path, :title, :content)
      end
  end
end
