# suppresses routing errors
if Rails.env.production?
  module ActionDispatch
    class DebugExceptions
      alias old_log_error log_error
      def log_error(env, wrapper)
        if wrapper.exception.is_a? ActionController::RoutingError
          nil
        else
          old_log_error env, wrapper
        end
      end
    end
  end
end
