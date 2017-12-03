module Admin
  class CustomFilesController < Admin::BaseController
    before_action :set_custom_file, only: [:destroy]
    after_action :delete_tmp_file, only: [:create]

    def index
      @custom_files = CustomFile.all
    end

    def new
      @custom_file = CustomFile.new
    end

    def create
      uploaded_file = custom_file_params[:file]
      return redirect_to new_admin_custom_file_path if uploaded_file.blank?

      filename = uploaded_file.original_filename
      @output_path = Rails.root.join('tmp', uploaded_file.original_filename)
      File.open(@output_path, 'w+b') do |fp|
        fp.write  uploaded_file.read
      end

      upload_file_list = [@output_path]
      CloudConfig::SERVICE.upload_files(CloudConfig::SERVICE.config.image_bucket_name, upload_file_list, 'custom-files')

      existing_record = CustomFile.where(path: filename).first
      if existing_record.nil?
        @custom_file = CustomFile.create(path: filename, description: custom_file_params[:description])
      else
        @custom_file = existing_record
        @custom_file.description = custom_file_params[:description]
      end

      if @custom_file.save
        redirect_to admin_custom_files_path
      else
        render 'new'
      end
    end

    def destroy
      @custom_file.destroy
      CloudConfig::SERVICE.delete_files(
        CloudConfig::SERVICE.config.image_bucket_name,
        [{ key: "custom-files/#{@custom_file.path}" }],
      )
      redirect_to admin_custom_files_path
    end

    private

      def custom_file_params
        params.require(:custom_file).permit(:file, :description)
      end

      def set_custom_file
        @custom_file = CustomFile.find(params[:id])
      end

      def delete_tmp_file
        File.delete @output_path if File.exist?(@output_path)
      end
  end
end
