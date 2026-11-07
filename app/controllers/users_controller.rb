class UsersController < ApplicationController
  include CrossOriginAccess
  allow_cross_origin_access only: :embedded
  before_action :authenticate_user!, only: [:index]
  before_action :username_to_id, only: [:show, :embedded]
  skip_forgery_protection only: [:embedded]

  def index
    user_id = current_user.id
    @user = User.find(user_id)
    @slides = user_slide_with_paginate(user_id, include_private_and_non_published: true)
    @tags = Slide.
            owner(user_id).
            tag_counts_on(:tags).order('count DESC')
  end

  def show
    user_id = params[:id]
    @user = User.find(user_id)
    @slides = user_slide_with_paginate(user_id)
    ensure_page_in_range(@slides)
    @tags = Slide.published.
            owner(user_id).
            tag_counts_on(:tags).order('count DESC')
    respond_to do |format|
      format.html
      format.rss
    end
  end

  def embedded
    @slides = user_slide_with_paginate(params[:id], per_page: 5)

    # 埋め込み先の要素の id に使う。英数字・ハイフン・下線だけを受け付ける
    @prefix = if params[:prefix].to_s.match?(/\A[0-9A-Za-z_-]{1,64}\z/)
                params[:prefix]
              else
                view_context.js_prefix
              end

    @body = render_to_string partial: 'embedded', locals: { slides: @slides, prefix: @prefix }
    render layout: false, content_type: 'application/javascript'
  end

  private

    # 真偽値や件数を位置で渡すと取り違えるので、キーワード引数にする
    def user_slide_with_paginate(user_id, include_private_and_non_published: false, per_page: 30)
      slides = if params[:sort_by] == 'popularity'
                 Slide.popular
               else
                 Slide.latest
               end
      unless include_private_and_non_published
        slides = slides.published
      end
      slides.owner(user_id).
        includes(:user).
        paginate(page: params[:page], per_page: per_page)
    end

    def username_to_id
      if params.key?(:username)
        params[:id] = UserFinder.username_to_id(params[:username])
      end
    end
end
