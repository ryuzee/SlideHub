class HtmlPlayerController < ApplicationController
  include SlideUtil
  before_action :set_slide
  layout 'simple'
  # ほかのサイトに iframe で埋め込んで使うので、枠での表示を許す
  after_action { response.headers.delete('X-Frame-Options') }

  def show
    @slide.record_access(:embedded_view)
  end
end
