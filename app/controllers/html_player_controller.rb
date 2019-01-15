class HtmlPlayerController < ApplicationController
  include SlideUtil
  before_action :set_slide
  layout 'simple'

  def show
    @slide.record_access(:embedded_view)
  end
end
