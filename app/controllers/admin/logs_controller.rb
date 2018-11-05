module Admin
  class LogsController < Admin::BaseController
    before_action :retrieve

    def index; end

    def show
      @path = params[:path]
      @result = []
      return redirect_to admin_logs_index_path, notice: t(:no_logs) unless @files.include?(@path)

      require 'io'
      require 'log_util'
      open(@path) do |io|
        io.tail(300).each do |line|
          @result.push SlideHub::LogUtil.escape_to_html(line)
        end
      end
    end

    def download
      path = params[:path]
      return redirect_to admin_logs_index_path, notice: t(:no_logs) unless @files.include?(path)

      stat = File.stat(path)
      send_file(path, filename: File.basename(path), length: stat.size)
    end

    private

      def retrieve
        path = Rails.root.join('log', '*')
        @files = Dir.glob(path)
      end
  end
end
