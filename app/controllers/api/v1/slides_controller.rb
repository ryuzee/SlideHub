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
module Api
  # :reek:UncommunicativeModuleName { enabled: false }
  module V1
    class SlidesController < Api::V1::BaseController
      def index
        @slides = Slide.all.published.latest.includes(:user).includes(:category)
        if params['name']
          @slides = @slides.where('name like ?', "%#{params["name"]}%")
        elsif params[:tag]
          @slides = @slides.tagged_with(params[:tag])
        end
      end

      def show
        @slide = Slide.where(id: params[:id]).published.includes(:user).includes(:category).first
        unless @slide
          not_found
        end
      end

      def transcript
        @slide = Slide.where(id: params[:id]).published.includes(:user).includes(:category).first
        unless @slide
          not_found
        end
      end
    end
  end
end
