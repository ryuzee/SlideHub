class SlidesController < ApplicationController
  before_action :authenticate_user!, only: [:edit, :update, :new, :create, :destroy]
  include SqsUsable
  protect_from_forgery except: :embedded

  def index
    @latest_slides = Slide.where('convert_status = 100')
      .order('created_at desc')
      .limit(8)
    @popular_slides = Slide.where('convert_status = 100')
      .order('total_view desc')
      .limit(8)
  end

  def latest
    @slides = Slide.where('convert_status = 100')
      .order('created_at desc')
      .paginate(page: params[:page], per_page: 20)
  end

  def popular
    @slides = Slide.where('convert_status = 100')
      .order('total_view desc')
      .paginate(page: params[:page], per_page: 20)
  end

  def category
    @slides = Slide.where('convert_status = 100')
      .where('category_id = ?', params[:id])
      .order('created_at desc')
      .paginate(page: params[:page], per_page: 20)

    Category.select('name')
    @category = Category.find(params[:id])
  end

  def show
    @slide = Slide.find(params[:id])
    @slide.increment(:page_view).increment(:total_view).save
    @start_position = 0 # 0? 1?
    if user_signed_in?
      @comment = @slide.comments.new
    end
    @posted_comments = @slide.comments.recent.limit(10).all
    @other_slides = Slide.where('convert_status = 100')
      .where('category_id = ?', @slide.category_id)
      .where('id != ?', @slide.id)
      .order('created_at desc')
      .limit(10)
  end

  def new
    @slide = Slide.new
  end

  def destroy
    @slide = Slide.find(params[:id])
    if @slide.user_id == current_user.id
      delete_slide_from_s3(@slide.key)
      delete_generated_files_from_s3(@slide.key)
      @slide.destroy
    end
    redirect_to '/users/index'
  end

  def create
    key = params[:slide][:key]
    if Slide.where('slides.key = ?', key).count > 0
      redirect_to '/slides'
    end

    slide_params = params.require(:slide).permit(:name, :description, :key, :downloadable, :category_id, :tag_list)
    @slide = Slide.new(slide_params)
    @slide.user_id = current_user.id
    if @slide.save
      slide = Slide.where('slides.key = ?', key).first
      send_message({ id: slide.id, key: key }.to_json)
      redirect_to "/slides/#{slide.id}"
    else
      render :new
    end
  end

  def edit
    @slide = Slide.find(params[:id])
    if current_user.id != @slide.user_id
      redirect_to "/slides/#{@slide.id}"
    end
  end

  def update
    params.permit! # @TODO やっちゃいけない
    @slide = Slide.find(params[:id])
    if current_user.id != @slide.user_id
      redirect_to "/slides/#{@slide.id}"
    end

    @slide.assign_attributes(params[:slide])
    if @slide.update_attributes(params[:slide])
      send_message({ id: @slide.id, key: @slide.key }.to_json)
      redirect_to "/slides/#{@slide.id}"
    else
      render :edit
    end
  end

  def search
    ransack_params = params[:q]
    # Hack to delete params can't be used by ransack
    tag_search = ransack_params['tag_search'].split(',') if ransack_params.present? && ransack_params['tag_search'].present?
    ransack_params.delete('tag_search') if ransack_params.present?

    table = tag_search ? Slide.tagged_with(tag_search, :any => true) : Slide
    @q = table.search(ransack_params)
    @slides = @q.result(distinct: true)
      .where('convert_status = 100')
      .order('created_at desc')
      .paginate(page: params[:page], per_page: 20)
  end

  def update_view
    count = 0
    begin
      @slide = Slide.find(params[:id])
      resp = get_pages_list(@slide.key)
      if resp
        count = resp.count
      else
        count = 0
      end
    rescue ActiveRecord::RecordNotFound => e
      count = 0
    end
    render json: count
  end

  def embedded
    @slide = Slide.find(params[:id])
    @slide.increment(:page_view).increment(:embedded_view).save
    @start_position = 0 # 0? 1?
    s = render_to_string :layout => 'plain', collection: @slide
    render text: s, :layout => false, content_type: "text/javascript"
  end

end
