class PlayerController < ApplicationController
  include SlideUtil
  before_action :set_slide

  def show
    prepare_content
    render layout: false, content_type: 'application/javascript'
  end

  def show_v2
    prepare_content
    render layout: false, content_type: 'application/javascript'
  end

  private

    def prepare_content
      # increment only when the player is embedded in other site...
      unless params.key?(:inside) && params[:inside] == '1'
        @slide.record_access(:embedded_view)
      end

      if params.has_key?(:prefix) && !params[:prefix].empty?
        @prefix = params[:prefix]
      else
        @prefix = view_context.js_prefix
      end

      @start_position = slide_position
      @body = render_to_string partial: 'body', locals: { slide: @slide, prefix: @prefix }
      script = render_to_string partial: 'js', locals: { prefix: @prefix, start_position: @start_position }
      @script = script.gsub!('OSSJSPARTS', "OSSJSPARTS#{@prefix}").gsub('PREFIX', @prefix)
    end

    def slide_position
      position = 1
      position = params[:page].to_i if params.key?(:page) && params[:page].to_i > 0
      position
    end

end
