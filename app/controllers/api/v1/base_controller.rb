module Api
  # :reek:UncommunicativeModuleName { enabled: false }
  module V1
    class BaseController < ApplicationController
      private

        def not_found
          render json: { 'error' => 'No data found' }, status: 404
        end
    end
  end
end
