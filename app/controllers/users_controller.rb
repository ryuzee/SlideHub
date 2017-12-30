# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(32)       not null
#  display_name           :string(128)      not null
#  password               :string(255)      default(""), not null
#  admin                  :boolean          default(FALSE), not null
#  disabled               :boolean          default(FALSE)
#  created_at             :datetime         not null
#  updated_at             :datetime
#  biography              :text(65535)
#  slides_count           :integer          default(0)
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  avatar_file_name       :string(255)
#  avatar_content_type    :string(255)
#  avatar_file_size       :integer
#  avatar_updated_at      :datetime
#

class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:index]
  before_action :username_to_id, only: [:show, :embedded]

  def index
    user_id = current_user.id
    @user = User.find(user_id)
    @slides = user_slide_with_paginate(user_id)
    @tags = Slide.
            owner(user_id).
            tag_counts_on(:tags).order('count DESC')
  end

  def show
    user_id = params[:id]
    @user = User.find(user_id)
    @slides = user_slide_with_paginate(user_id)
    @tags = Slide.published.
            owner(user_id).
            tag_counts_on(:tags).order('count DESC')
    respond_to do |format|
      format.html {}
      format.rss {}
    end
  end

  def embedded
    @slides = user_slide_with_paginate(params[:id], 5)
    uglified_js = render_to_string layout: 'javascript', collection: @slide
    render plain: uglified_js, layout: false, content_type: 'application/javascript'
  end

  private

    def user_slide_with_paginate(user_id, slides_per_page = 30)
      slides = if params[:sort_by] == 'popularity'
                 Slide.published.popular
               else
                 Slide.published.latest
               end
      slides = slides.owner(user_id).
               includes(:user).
               paginate(page: params[:page], per_page: slides_per_page)
      slides
    end

    def username_to_id
      if params.key?(:username)
        params[:id] = User.username_to_id(params[:username])
      end
    end
end
