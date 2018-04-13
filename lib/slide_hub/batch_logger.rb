module SlideHub
  module BatchLogger
    class << self
      delegate(
        :debug,
        :info,
        :warn,
        :error,
        :fatal,
        to: :logger,
      )

      def logger
        @logger ||= begin
          logger = ActiveSupport::Logger.new(Rails.root.join('log', "batch_#{Rails.env}.log"), 5, 10 * 1024 * 1024)
          logger.formatter = Logger::Formatter.new
          logger.datetime_format = '%Y-%m-%d %H:%M:%S'

          stdout_logger = ActiveSupport::Logger.new(STDOUT)
          stdout_logger.formatter = Logger::Formatter.new
          stdout_logger.datetime_format = '%Y-%m-%d %H:%M:%S'
          multiple_loggers =
            ActiveSupport::Logger.broadcast(stdout_logger)
          logger.extend(multiple_loggers)

          logger
        end
      end
    end
  end
end
