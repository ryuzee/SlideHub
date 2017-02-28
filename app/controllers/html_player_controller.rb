class HtmlPlayerController < ApplicationController
  include SlideUtil
  before_action :set_slide
  layout 'simple'

  def show
    @slide.increment(:page_view).increment(:total_view).save
    @slide.increment(:page_view).increment(:embedded_view).save
  end
end
