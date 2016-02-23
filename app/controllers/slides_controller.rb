class SlidesController < ApplicationController
  before_action :authenticate_user!, only: [:edit, :update, :new, :create, :destroy]
  before_action :duplicate_key_check!, only: [:create]
  include SqsUsable
  protect_from_forgery except: [:embedded]

  def index
    @latest_slides = Slide.published.latest.limit(8).includes(:user)
    @popular_slides = Slide.published.popular.limit(8).includes(:user)
  end

  def latest
    @slides = Slide.published.latest.includes(:user).
              paginate(page: params[:page], per_page: 20)
    respond_to do |format|
      format.html
      format.rss
    end
  end

  def popular
    @slides = Slide.published.popular.includes(:user).
              paginate(page: params[:page], per_page: 20)
    respond_to do |format|
      format.html
      format.rss
    end
  end

  def category
    @slides = Slide.published.latest.category(params[:category_id]).includes(:user).
              paginate(page: params[:page], per_page: 20)

    Category.select('name')
    @category = Category.find(params[:category_id])
  end

  def show
    @slide = Slide.find(params[:id])
    @slide.increment(:page_view).increment(:total_view).save
    @start_position = slide_position
    if user_signed_in?
      @comment = @slide.comments.new
    end
    @posted_comments = @slide.comments.recent.limit(10).all.includes(:user)
    @other_slides = Slide.published.latest.
                    where('category_id = ?', @slide.category_id).
                    where('id != ?', @slide.id).
                    limit(10).
                    includes(:user)
  end

  def new
    @slide = Slide.new
  end

  def destroy
    @slide = Slide.find(params[:id])
    if @slide.user_id == current_user.id
      storage = Storage.new
      storage.delete_slide(@slide.key)
      storage.delete_generated_files(@slide.key)
      @slide.destroy
    end
    redirect_to slides_path
  end

  def create
    key = params[:slide][:key]
    slide_params = params.require(:slide).permit(:name, :description, :key, :downloadable, :category_id, :tag_list)
    @slide = Slide.new(slide_params)
    @slide.user_id = current_user.id
    if @slide.save
      slide = Slide.where('slides.key = ?', key).first
      send_message({ id: slide.id, key: key }.to_json)
      redirect_to slide_path(slide.id)
    else
      render :new
    end
  end

  def edit
    @slide = Slide.find(params[:id])
    if current_user.id != @slide.user_id
      redirect_to slide_path(@slide.id)
    end
  end

  def update
    slide_params = params.require(:slide).permit(:name, :description, :key, :downloadable, :category_id, :tag_list, :convert_status)
    @slide = Slide.find(params[:id])
    if current_user.id != @slide.user_id
      return redirect_to slide_path(@slide.id)
    end
    slide_convert_status = params[:slide][:convert_status].to_i

    @slide.assign_attributes(slide_params)
    if @slide.update_attributes(slide_params)
      if slide_convert_status == 0
        send_message({ id: @slide.id, key: @slide.key }.to_json)
      end
      redirect_to slide_path(@slide.id)
    else
      render :edit
    end
  end

  def search
    ransack_params = params[:q]
    # Hack to delete params can't be used by ransack
    tag_search = ransack_params['tag_search'].split(',') if ransack_params.present? && ransack_params['tag_search'].present?
    ransack_params.delete('tag_search') if ransack_params.present?

    table = tag_search ? Slide.tagged_with(tag_search, any: true) : Slide
    @q = table.search(ransack_params)
    @slides = @q.result(distinct: true).
              published.latest.
              includes(:user).
              paginate(page: params[:page], per_page: 20)
  end

  def update_view
    count = 0
    begin
      @slide = Slide.find(params[:id])
      resp = @slide.page_list
      count = if resp
                resp.count
              else
                0
              end
    rescue ActiveRecord::RecordNotFound => e
      count = 0
    end
    render json: count
  end

  def embedded
    @slide = Slide.find(params[:id])
    # increment only when the player is embedded in other site...
    unless params.has_key?(:inside) && params[:inside] == '1'
      @slide.increment(:embedded_view).increment(:total_view).save
    end
    @start_position = slide_position
    s = render_to_string layout: 'plain', collection: @slide
    render text: s, layout: false, content_type: 'application/javascript'
  end

  def download
    @slide = Slide.find(params[:id])
    storage = Storage.new
    url = storage.get_slide_download_url(@slide.key)
    # @TODO: handle response code
    require 'open-uri'
    data = open(url).read
    send_data data, disposition: 'attachment', filename: "#{@slide.key}#{@slide.extension}"
  end

  private

    def duplicate_key_check!
      key = params[:slide][:key]
      if Slide.where('slides.key = ?', key).count > 0
        redirect_to slides_path
      end
    end

    def slide_position
      if params.has_key?(:page)
        position = params[:page].to_i
        if position <= 0
          position = 1
        end
      else
        position = 1
      end
      position
    end
end
