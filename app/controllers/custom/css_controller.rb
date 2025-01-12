module Custom
  class CssController < ApplicationController
    def show
      respond_to(&:css)
    end
  end
end
