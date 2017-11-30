module Custom
  class CssController < ApplicationController
    def show
      respond_to do |format|
        format.css
      end
    end
  end
end
