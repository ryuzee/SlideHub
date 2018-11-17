# suppresses routing errors
if Rails.env.production?
  class ActionDispatch::DebugExceptions
    alias_method :old_log_error, :log_error
    def log_error(env, wrapper)
      if wrapper.exception.is_a?  ActionController::RoutingError
        return
      else
        old_log_error env, wrapper
      end
    end
  end
end
