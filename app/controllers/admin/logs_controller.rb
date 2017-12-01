module Admin
  class LogsController < Admin::BaseController
    before_action :retrieve

    def index; end

    def show
      @path = params[:path]
      @result = []
      return unless @files.include?(@path)

      File.open(@path) do |file|
        file.read.split("\n").each do |line|
          @result.push line
        end
      end
    end

    private

      def retrieve
        path = Rails.root.join('log/*')
        @files = Dir.glob(path)
      end
  end
end
