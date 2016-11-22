class SlidePageCountController < ApplicationController
  include SlideUtil

  def show
    count = 0
    begin
      set_slide
      resp = @slide.page_list
      count = if resp
                resp.count
              else
                0
              end
    rescue ActiveRecord::RecordNotFound
      count = 0
    end
    render json: { page_count: count }
  end
end
