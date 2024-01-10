require 'batch_logger'
require 'cloud/queue/response'
require 'convert_util'
require 'image'
require 'tmpdir'

class ConvertProcedure
  def initialize(object_key:, logger:)
    @object_key = object_key
    @logger = logger
    @work_dir = ''
    @work_file = SecureRandom.hex.to_s
    @file_type = ''
    @slide_image_list = []
    @upload_file_list = []
    @convert_util = SlideHub::ConvertUtil.new(logger)
  end

  def run
    Dir.mktmpdir do |dir|
      @work_dir = dir
      logger.info("Current directory is #{work_dir}")
      return false unless save_file

      convert_to_ppm
      convert_to_jpg
      generate_json
      convert_to_thumbnail
      convert_to_transcript
      upload_files
      update_database
      true
    end
  end

  private

    attr_reader :logger, :work_dir, :object_key, :work_file, :convert_util

    def save_file
      return false unless CloudConfig::PROVIDER_ENGINE.save_file(CloudConfig::PROVIDER_ENGINE.config.bucket_name, object_key, "#{work_dir}/#{work_file}")

      @file_type = convert_util.get_slide_file_type("#{work_dir}/#{work_file}")
      true
    end

    def convert_to_ppm
      case @file_type
      when 'pdf'
        logger.info('Rename to PDF')
        convert_util.rename_to_pdf(work_dir, work_file)
        logger.info('Start converting from PDF to PPM')
        convert_util.pdf_to_ppm(work_dir, "#{work_file}.pdf")
        true
      when 'ppt', 'pptx'
        logger.info('Start converting from PPT to PDF')
        convert_util.ppt_to_pdf(work_dir, work_file)
        logger.info('Start converting from PDF to PPM')
        convert_util.pdf_to_ppm(work_dir, "#{work_file}.pdf")
        true
      else
        false
      end
    end

    def convert_to_jpg
      logger.info('Start converting from PPM to JPG')
      @slide_image_list = convert_util.ppm_to_jpg(work_dir)
      logger.info(convert_util.get_local_file_list(work_dir, '').inspect)
      @upload_file_list = @slide_image_list.dup
    end

    def convert_to_thumbnail
      logger.info('Generating thumbnails')
      logger.info(@slide_image_list.inspect)
      thumbnail_list = convert_util.jpg_to_thumbnail(@slide_image_list)
      thumbnail_list.each do |tm|
        @upload_file_list.push(tm)
      end if thumbnail_list.instance_of?(Array)
    end

    def convert_to_transcript
      transcript = convert_util.pdf_to_transcript(work_dir, "#{work_file}.pdf")
      @upload_file_list.push(transcript) if transcript
    end

    def generate_json
      save_list = []
      @slide_image_list.each do |item|
        save_list.push("#{object_key}/#{File.basename(item)}")
      end
      File.open("#{work_dir}/list.json", 'w') do |io|
        JSON.dump(save_list, io)
      end
      @upload_file_list.push("#{work_dir}/list.json")
    end

    def upload_files
      logger.info(@upload_file_list.inspect)
      CloudConfig::PROVIDER_ENGINE.upload_files(CloudConfig::PROVIDER_ENGINE.config.image_bucket_name, @upload_file_list, object_key)
    end

    def update_database
      # If multi-tenanted, update all database which includes specified object_key
      if ENV.fetch('OSS_MULTI_TENANT', false)
        tenants = Tenant.pluck(:name)
        tenants.each do |tenant|
          Apartment::Tenant.switch(tenant) do
            logger.info("tenant is #{tenant}")
            Slide.update_after_convert(object_key, @file_type, @slide_image_list.count)
          end
        end
        Apartment::Tenant.reset
      end
      # Update main database
      Slide.update_after_convert(object_key, @file_type, @slide_image_list.count)
    end
end
