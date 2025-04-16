class SitemapController < ApplicationController
  def index
    @slides = Slide.published.latest
    
    respond_to do |format|
      format.xml
    end
  end
end 