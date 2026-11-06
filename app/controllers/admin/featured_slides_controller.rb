module Admin
  class FeaturedSlidesController < Admin::BaseController
    CANDIDATE_LIMIT = 12

    def index
      @featured_slides = FeaturedSlide.ordered.includes(slide: :user)
      @featured_slide = FeaturedSlide.new
      @candidates = candidates
    end

    # 以前の「スライド ID を入力する」画面。追加は一覧画面でできるようにしたので一覧に戻す
    def new
      redirect_to admin_featured_slides_path
    end

    def create
      @featured_slide = FeaturedSlide.new(params.require(:featured_slide).permit(:slide_id))
      if @featured_slide.save
        redirect_to admin_featured_slides_path(q: params[:q].presence), notice: t(:featured_slide_was_added)
      else
        @featured_slides = FeaturedSlide.ordered.includes(slide: :user)
        @candidates = candidates
        render :index, status: :unprocessable_entity
      end
    end

    def destroy
      FeaturedSlide.find(params[:id]).destroy
      redirect_to admin_featured_slides_path, notice: t(:featured_slide_was_deleted)
    end

    # ドラッグや上下ボタンで並べ替えたときに、画面から ID の並びが送られてくる
    def reorder
      FeaturedSlide.reorder_by_ids(Array(params.require(:ids)))
      head :no_content
    end

    private

      # 追加候補: 公開中でまだ注目に入っていないスライド。タイトルで検索でき、空なら新しい順
      def candidates
        scope = Slide.published.includes(:user).where.not(id: FeaturedSlide.select(:slide_id))
        if params[:q].present?
          scope = scope.where('slides.name LIKE ?', "%#{Slide.sanitize_sql_like(params[:q])}%")
        end
        scope.latest.limit(CANDIDATE_LIMIT)
      end
  end
end
