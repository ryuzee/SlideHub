# == Schema Information
#
# Table name: slides
#
#  id             :integer          not null, primary key
#  user_id        :integer          not null
#  name           :string(255)      not null
#  description    :text(65535)      not null
#  downloadable   :boolean          default(FALSE), not null
#  category_id    :integer          not null
#  created_at     :datetime         not null
#  modified_at    :datetime
#  key            :string(255)      default("")
#  extension      :string(10)       default(""), not null
#  convert_status :integer          default(0)
#  total_view     :integer          default(0), not null
#  page_view      :integer          default(0)
#  download_count :integer          default(0), not null
#  embedded_view  :integer          default(0), not null
#  num_of_pages   :integer          default(0)
#  comments_count :integer          default(0), not null
#

class SlidesController < ApplicationController
  include SlideUtil
  before_action :set_slide, only: [:edit, :update, :show, :destroy, :embedded, :download]
  before_action :set_related_slides, only: [:show]
  before_action :authenticate_user!, only: [:edit, :update, :new, :create, :destroy]
  before_action :owner?, only: [:edit, :update, :destroy]
  before_action :duplicate_key?, only: [:create]
  before_action :downloadable?, only: [:download]

  protect_from_forgery except: [:embedded]

  def index
    @latest_slides = Slide.latest_slides(8)
    @popular_slides = Slide.popular_slides(8)
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

  def show
    @slide.increment(:page_view).increment(:total_view).save
    @start_position = slide_position
    if user_signed_in?
      @comment = @slide.comments.new
    end
    @posted_comments = @slide.comments.recent.limit(10).all.includes(:user)
  end

  def new
    @slide = Slide.new
    render "slides/#{CloudConfig.service_name}/new"
  end

  def destroy
    CloudConfig::SERVICE.delete_slide(@slide.key)
    CloudConfig::SERVICE.delete_generated_files(@slide.key)
    @slide.destroy
    redirect_to slides_path
  end

  def create
    key = params[:slide][:key]
    slide_params = params.require(:slide).permit(:name, :description, :key, :downloadable, :category_id, :tag_list)
    @slide = Slide.new(slide_params)
    @slide.user_id = current_user.id
    if @slide.save
      slide = Slide.where('slides.key = ?', key).first
      CloudConfig::SERVICE.send_message({ id: slide.id, key: key }.to_json)
      redirect_to slide_path(slide.id)
    else
      render "slides/#{CloudConfig.service_name}/new"
    end
  end

  def edit
    render "slides/#{CloudConfig.service_name}/edit"
  end

  def update
    slide_params = params.require(:slide).permit(:name, :description, :key, :downloadable, :category_id, :tag_list, :convert_status)
    slide_convert_status = params[:slide][:convert_status].to_i

    @slide.assign_attributes(slide_params)
    if @slide.update_attributes(slide_params)
      if slide_convert_status.zero?
        CloudConfig::SERVICE.send_message({ id: @slide.id, key: @slide.key }.to_json)
      end
      redirect_to slide_path(@slide.id)
    else
      render "slides/#{CloudConfig.service_name}/edit"
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
      set_slide
      resp = @slide.page_list
      count = if resp
                resp.count
              else
                0
              end
    rescue ActiveRecord::RecordNotFound
      count = 0
    end
    render json: { page_count: count }
  end

  def embedded
    # increment only when the player is embedded in other site...
    unless params.key?(:inside) && params[:inside] == '1'
      @slide.increment(:embedded_view).increment(:total_view).save
    end
    @start_position = slide_position
    s = render_to_string layout: 'plain', collection: @slide
    render text: s, layout: false, content_type: 'application/javascript'
  end

  def download
    @slide.increment(:download_count).save
    download_slide
  end

  private

    def set_slide
      @slide = Slide.find(params[:id])
    end

    def set_related_slides
      @related_slides = Slide.related_slides(@slide.category_id, @slide.id)
    end

    def owner?
      redirect_to slide_path(@slide.id) if current_user.id != @slide.user_id
    end

    def downloadable?
      redirect_to slide_path(@slide.id) if @slide.downloadable != true
    end

    def duplicate_key?
      redirect_to slides_path if Slide.key_exist?(params[:slide][:key])
    end

    def slide_position
      position = 1
      position = params[:page].to_i if params.key?(:page) && params[:page].to_i > 0
      position
    end
end
