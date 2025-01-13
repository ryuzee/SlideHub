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
          # メインのログファイル用ロガー
          file_logger = ActiveSupport::Logger.new(
            Rails.root.join('log', "batch_#{Rails.env}.log"), 5, 10 * 1024 * 1024
          )
          file_logger.formatter = Logger::Formatter.new
          file_logger.datetime_format = '%Y-%m-%d %H:%M:%S'

          # 標準出力用のロガー
          stdout_logger = ActiveSupport::Logger.new($stdout)
          stdout_logger.formatter = Logger::Formatter.new
          stdout_logger.datetime_format = '%Y-%m-%d %H:%M:%S'

          # ログの複数出力を管理するロガーを作成
          multi_logger = ActiveSupport::TaggedLogging.new(file_logger)
          multi_logger.extend(Module.new {
            define_method(:add) do |severity, message = nil, progname = nil, &block|
              file_logger.add(severity, message, progname, &block)
              stdout_logger.add(severity, message, progname, &block)
            end
          })

          multi_logger
        end
      end
    end
  end
end
