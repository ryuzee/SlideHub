module Admin
  class CustomFilesController < Admin::BaseController
    before_action :set_custom_file, only: [:destroy]
    before_action :attached_check, only: [:create]
    after_action :delete_tmp_file, only: [:create]

    def index
      @custom_files = CustomFile.all
    end

    def new
      @custom_file = CustomFile.new
    end

    def create
      save_tmp_file(custom_file_params[:file])

      CloudConfig::SERVICE.upload_files(CloudConfig::SERVICE.config.image_bucket_name, [@output_path], 'custom-files')

      filename = custom_file_params[:file].original_filename
      description = custom_file_params[:description]

      existing_record = CustomFile.where(path: filename).first
      if existing_record
        custom_file = existing_record
        custom_file.description = description
      else
        custom_file = CustomFile.create(path: filename, description: description)
      end

      custom_file.save!
      redirect_to admin_custom_files_path, notice: t(:custom_files_were_saved)
    end

    def destroy
      @custom_file.destroy
      CloudConfig::SERVICE.delete_files(
        CloudConfig::SERVICE.config.image_bucket_name,
        [{ key: "custom-files/#{@custom_file.path}" }],
      )
      redirect_to admin_custom_files_path, notice: t(:custom_files_were_deleted)
    end

    private

      def custom_file_params
        params.require(:custom_file).permit(:file, :description)
      end

      def set_custom_file
        @custom_file = CustomFile.find(params[:id])
      end

      def attached_check
        redirect_to new_admin_custom_file_path, notice: t(:no_attached_file) if custom_file_params[:file].blank?
      end

      def save_tmp_file(uploaded_file)
        FileUtils.mkdir_p(Rails.root.join('tmp')) unless FileTest.exist?(Rails.root.join('tmp'))
        @output_path = Rails.root.join('tmp', uploaded_file.original_filename)
        File.open(@output_path, 'w+b') do |fp|
          fp.write  uploaded_file.read
        end
      end

      def delete_tmp_file
        File.delete @output_path if File.exist?(@output_path)
      end
  end
end
