module Api
  # :reek:UncommunicativeModuleName { enabled: false }
  module V1
    class BaseController < ApplicationController
      include CrossOriginAccess
      allow_cross_origin_access

      private

        def not_found
          render json: { 'error' => 'No data found' }, status: :not_found
        end
    end
  end
end
