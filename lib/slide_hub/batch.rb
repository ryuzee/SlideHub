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
      SlideHub::BatchLogger.info("Start converting slide. id=#{obj['id']} key=#{obj['key']}")
      result = BatchProcedure.new.convert_slide(obj['key'])
      if result
        SlideHub::BatchLogger.info("Delete message from Queue. id=#{obj['id']} key=#{obj['key']}")
        CloudConfig::SERVICE.delete_message(msg)
      else
        SlideHub::BatchLogger.error("Slide conversion failed. id=#{obj['id']} key=#{obj['key']}")
      end
    end
  end
end

class BatchProcedure
  def convert_slide(key)
    Dir.mktmpdir do |dir|
      SlideHub::BatchLogger.info("Current directory is #{dir}")
      file = SecureRandom.hex.to_s
      CloudConfig::SERVICE.save_file(CloudConfig::SERVICE.config.bucket_name, key, "#{dir}/#{file}")
      file_type = SlideHub::ConvertUtil.new.get_slide_file_type("#{dir}/#{file}")

      convert_to_ppm(file_type, file, dir)
      slide_image_list = convert_to_jpg(dir)
      upload_file_list = slide_image_list.dup

      generate_json_list(slide_image_list, key, "#{dir}/list.json")
      upload_file_list.push("#{dir}/list.json")

      SlideHub::BatchLogger.info('Generating thumbnails')
      SlideHub::BatchLogger.info(slide_image_list.inspect)
      thumbnail_list = SlideHub::ConvertUtil.new.jpg_to_thumbnail(slide_image_list)
      thumbnail_list.each do |tm|
        upload_file_list.push(tm)
      end if thumbnail_list.instance_of?(Array)

      transcript = SlideHub::ConvertUtil.new.pdf_to_transcript(dir, "#{file}.pdf")
      upload_file_list.push(transcript) if transcript

      SlideHub::BatchLogger.info(upload_file_list.inspect)
      CloudConfig::SERVICE.upload_files(CloudConfig::SERVICE.config.image_bucket_name, upload_file_list, key)

      update_database(key, file_type, slide_image_list.count)
      true
    end
  end

  private

    def convert_to_ppm(file_type, file, dir)
      SlideHub::BatchLogger.info("File Type is #{file_type}")
      case file_type
      when 'pdf'
        SlideHub::BatchLogger.info('Rename to PDF')
        SlideHub::ConvertUtil.new.rename_to_pdf(dir, file)
        SlideHub::BatchLogger.info('Start converting from PDF to PPM')
        SlideHub::ConvertUtil.new.pdf_to_ppm(dir, "#{file}.pdf")
        true
      when 'ppt', 'pptx'
        SlideHub::BatchLogger.info('Start converting from PPT to PDF')
        SlideHub::ConvertUtil.new.ppt_to_pdf(dir, file)
        SlideHub::BatchLogger.info(SlideHub::ConvertUtil.new.get_local_file_list(dir, '').inspect)
        SlideHub::BatchLogger.info('Start converting from PDF to PPM')
        SlideHub::ConvertUtil.new.pdf_to_ppm(dir, "#{file}.pdf")
        SlideHub::BatchLogger.info(SlideHub::ConvertUtil.new.get_local_file_list(dir, '').inspect)
        true
      else
        false
      end
    end

    def convert_to_jpg(dir)
      SlideHub::BatchLogger.info('Start converting from PPM to JPG')
      slide_image_list = SlideHub::ConvertUtil.new.ppm_to_jpg(dir)
      SlideHub::BatchLogger.info(SlideHub::ConvertUtil.new.get_local_file_list(dir, '').inspect)
      slide_image_list
    end

    def generate_json_list(list, prefix, filename)
      save_list = []
      list.each do |item|
        save_list.push("#{prefix}/#{File.basename(item)}")
      end
      open(filename, 'w') do |io|
        JSON.dump(save_list, io)
      end
    end

    def update_database(key, file_type, num_of_pages)
      slide = Slide.where('slides.key = ?', key).first
      slide.convert_status = 100
      slide.extension = ".#{file_type}"
      slide.num_of_pages = num_of_pages
      slide.save
    end
end
