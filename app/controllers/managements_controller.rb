class ManagementsController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_user!

  def dashboard
    @slide_count = Slide.count
    @user_count = User.count
    @conversion_failed_count = Slide.failed.count
    @comment_count = Comment.count

    s = Slide.arel_table
    rec = Slide.select([s[:page_view].sum.as('page_view'), s[:download_count].sum.as('download_count'), s[:embedded_view].sum.as('embedded_view')]).all[0]
    @page_view = rec.page_view
    @download_count = rec.download_count
    @embedded_view = rec.embedded_view

    @latest_slides = Slide.published.latest.
                     includes(:user).
                     limit(10)
    @popular_slides = Slide.published.popular.
                      includes(:user).
                      limit(10)
  end

  def user_list
    ransack_params = params[:q]
    @q = User.search(ransack_params)
    @users = @q.result(distinct: true).
             latest.
             paginate(page: params[:page], per_page: 20)
  end

  def slide_list
    ransack_params = params[:q]
    @q = Slide.search(ransack_params)
    @slides = @q.result(distinct: true).
              latest.
              paginate(page: params[:page], per_page: 20)
  end

  def slide_edit
    @slide = Slide.find(params[:id])
  end

  def slide_update
    params.permit! # @TODO やっちゃいけない
    @slide = Slide.find(params[:slide][:id])
    @slide.assign_attributes(params[:slide])
    if @slide.update_attributes(params[:slide])
      redirect_to "/managements/slide_edit/#{@slide.id}"
    else
      render :edit
    end
  end

  def custom_contents_setting
    @settings = CustomSetting.unscoped.where("var like 'custom_content.%'")
  end

  def custom_contents_update
    params.require(:settings).map do |param|
      data = param.to_hash
      CustomSetting[data['var']] = data['value']
    end
    redirect_to '/managements/custom_contents_setting'
  end

  def site_setting
    @settings = CustomSetting.unscoped.where("var like 'site.%'")
  end

  def site_update
    params.require(:settings).map do |param|
      data = param.to_hash
      CustomSetting[data['var']] = data['value']
    end
    redirect_to '/managements/site_setting'
  end

  private

    def admin_user!
      if !user_signed_in? || !current_user.admin
        redirect_to new_user_session_path
      end
    end
end
