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
#  updated_at     :datetime
#  object_key     :string(255)      default("")
#  extension      :string(10)       default(""), not null
#  convert_status :integer          default(0)
#  total_view     :integer          default(0), not null
#  page_view      :integer          default(0)
#  download_count :integer          default(0), not null
#  embedded_view  :integer          default(0), not null
#  num_of_pages   :integer          default(0)
#  comments_count :integer          default(0), not null
#

# :reek:TooManyInstanceVariables { enabled: false }
class SlidesController < ApplicationController
  include SlideUtil
  before_action :set_slide, only: [:edit, :update, :show, :destroy]
  before_action :set_related_slides, only: [:show]
  before_action :authenticate_user!, only: [:edit, :update, :new, :create, :destroy]
  before_action :owner?, only: [:edit, :update, :destroy]
  before_action :uploadable?, only: [:new, :create]
  before_action :duplicate_key?, only: [:create]

  protect_from_forgery

  def index
    @slide_index = SlideIndex.new
  end

  def show
    @slide.record_access(:page_view)
    @start_position = slide_position
    if user_signed_in?
      @comment = @slide.comments.new
    end
    @posted_comments = @slide.comments.limit(10).all.includes(:user)
  end

  def new
    @slide = Slide.new
    render "slides/#{CloudConfig.service_name}/new"
  end

  def destroy
    @slide.delete_uploaded_files
    @slide.destroy
    redirect_to slides_path
  end

  def create
    key = params[:slide][:object_key]
    slide_params = params.require(:slide).permit(:name, :description, :object_key, :downloadable, :category_id, :tag_list, :private)
    @slide = Slide.new(slide_params)
    @slide.user_id = current_user.id
    if @slide.save
      slide = Slide.where('slides.object_key = ?', key).first
      slide.send_convert_request
      redirect_to slide_path(slide.id)
    else
      render "slides/#{CloudConfig.service_name}/new"
    end
  end

  def edit
    render "slides/#{CloudConfig.service_name}/edit"
  end

  def update
    slide_params = params.require(:slide).permit(:name, :description, :object_key, :downloadable, :category_id, :tag_list, :convert_status, :private)

    @slide.assign_attributes(slide_params)
    if @slide.update(slide_params)
      @slide.send_convert_request unless @slide.converted?
      redirect_to slide_path(@slide.id)
    else
      render "slides/#{CloudConfig.service_name}/edit"
    end
  end

  private

    def set_related_slides
      @related_slides = Slide.related_slides(@slide.category_id, @slide.id)
    end

    def owner?
      redirect_to slide_path(@slide.id) if current_user.id != @slide.user_id
    end

    def uploadable?
      redirect_to slides_path, flash: { warning: t(:no_permission) } unless @uploadable
    end

    def duplicate_key?
      redirect_to slides_path if Slide.key_exist?(params[:slide][:object_key])
    end
end
