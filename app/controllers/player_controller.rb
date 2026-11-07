class PlayerController < ApplicationController
  include SlideUtil
  include CrossOriginAccess
  allow_cross_origin_access
  before_action :set_slide
  skip_forgery_protection

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

      # JavaScript の名前と要素の id の一部になるので、英数字と下線だけを受け付ける
      @prefix = if params[:prefix].to_s.match?(/\A[0-9A-Za-z_]{1,64}\z/)
                  params[:prefix]
                else
                  view_context.js_prefix
                end

      @start_position = slide_position
      @body = render_to_string partial: 'body', locals: { slide: @slide, prefix: @prefix }
      # プレイヤーの動きの JavaScript は、目印のまま描画して圧縮済みのものを使い回す（PlayerScript）
      template = render_to_string partial: 'js'
      @script = PlayerScript.build(template, prefix: @prefix, start_index: @start_position - 1)
    end

    def slide_position
      position = 1
      position = params[:page].to_i if params.key?(:page) && params[:page].to_i.positive?
      position
    end
end
