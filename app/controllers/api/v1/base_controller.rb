module Api
  # :reek:UncommunicativeModuleName { enabled: false }
  module V1
    class BaseController < ApplicationController
      private

        def not_found
          render json: { 'error' => 'No data found' }, status: :not_found
        end
    end
  end
end
