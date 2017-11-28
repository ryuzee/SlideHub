module Custom
  class CssController < ApplicationController
    def show
      # @room = Room.find(params[:id])
      respond_to do |format|
        format.css
      end
    end
  end
end
