require 'batch_logger'
require 'cloud/queue/response'
require 'convert_util'
require 'image'
require 'tmpdir'

class Batch
  def self.execute
    SlideHub::BatchLogger.info('Start convert process')
    resp = CloudConfig::SERVICE.receive_message(5)
    unless resp.exist?
      SlideHub::BatchLogger.info('No Queue message found')
      return true
    end

    resp.messages.each do |msg|
      obj = JSON.parse(msg.body)
      SlideHub::BatchLogger.info("Start converting slide. id=#{obj['id']} object_key=#{obj['object_key']}")
      result = BatchProcedure.new.convert_slide(obj['object_key'])
      if result
        SlideHub::BatchLogger.info("Delete message from Queue. id=#{obj['id']} object_key=#{obj['object_key']}")
        CloudConfig::SERVICE.delete_message(msg)
      else
        SlideHub::BatchLogger.error("Slide conversion failed. id=#{obj['id']} object_key=#{obj['object_key']}")
      end
    end
  end
end

class BatchProcedure
  def initialize
    @work_dir = ''
    @work_file = SecureRandom.hex.to_s
    @file_type = ''
    @slide_image_list = []
    @upload_file_list = []
  end

  def convert_slide(object_key)
    @object_key = object_key
    Dir.mktmpdir do |dir|
      @work_dir = dir
      SlideHub::BatchLogger.info("Current directory is #{@work_dir}")
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

    def save_file
      return false unless CloudConfig::SERVICE.save_file(CloudConfig::SERVICE.config.bucket_name, @object_key, "#{@work_dir}/#{@work_file}")
      @file_type = SlideHub::ConvertUtil.new.get_slide_file_type("#{@work_dir}/#{@work_file}")
      true
    end

    def convert_to_ppm
      SlideHub::BatchLogger.info("File Type is #{@file_type}")
      case @file_type
      when 'pdf'
        SlideHub::BatchLogger.info('Rename to PDF')
        SlideHub::ConvertUtil.new.rename_to_pdf(@work_dir, @work_file)
        SlideHub::BatchLogger.info('Start converting from PDF to PPM')
        SlideHub::ConvertUtil.new.pdf_to_ppm(@work_dir, "#{@work_file}.pdf")
        true
      when 'ppt', 'pptx'
        SlideHub::BatchLogger.info('Start converting from PPT to PDF')
        SlideHub::ConvertUtil.new.ppt_to_pdf(@work_dir, @work_file)
        SlideHub::BatchLogger.info(SlideHub::ConvertUtil.new.get_local_file_list(@work_dir, '').inspect)
        SlideHub::BatchLogger.info('Start converting from PDF to PPM')
        SlideHub::ConvertUtil.new.pdf_to_ppm(@work_dir, "#{@work_file}.pdf")
        SlideHub::BatchLogger.info(SlideHub::ConvertUtil.new.get_local_file_list(@work_dir, '').inspect)
        true
      else
        false
      end
    end

    def convert_to_jpg
      SlideHub::BatchLogger.info('Start converting from PPM to JPG')
      @slide_image_list = SlideHub::ConvertUtil.new.ppm_to_jpg(@work_dir)
      SlideHub::BatchLogger.info(SlideHub::ConvertUtil.new.get_local_file_list(@work_dir, '').inspect)
      @upload_file_list = @slide_image_list.dup
    end

    def convert_to_thumbnail
      SlideHub::BatchLogger.info('Generating thumbnails')
      SlideHub::BatchLogger.info(@slide_image_list.inspect)
      thumbnail_list = SlideHub::ConvertUtil.new.jpg_to_thumbnail(@slide_image_list)
      thumbnail_list.each do |tm|
        @upload_file_list.push(tm)
      end if thumbnail_list.instance_of?(Array)
    end

    def convert_to_transcript
      transcript = SlideHub::ConvertUtil.new.pdf_to_transcript(@work_dir, "#{@work_file}.pdf")
      @upload_file_list.push(transcript) if transcript
    end

    def generate_json
      save_list = []
      @slide_image_list.each do |item|
        save_list.push("#{@object_key}/#{File.basename(item)}")
      end
      open("#{@work_dir}/list.json", 'w') do |io|
        JSON.dump(save_list, io)
      end
      @upload_file_list.push("#{@work_dir}/list.json")
    end

    def upload_files
      SlideHub::BatchLogger.info(@upload_file_list.inspect)
      CloudConfig::SERVICE.upload_files(CloudConfig::SERVICE.config.image_bucket_name, @upload_file_list, @object_key)
    end

    def update_database
      slide = Slide.where('slides.object_key = ?', @object_key).first
      slide.convert_status = 100
      slide.extension = ".#{@file_type}"
      slide.num_of_pages = @slide_image_list.count
      slide.save
    end
end
