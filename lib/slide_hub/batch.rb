require 'batch_logger'
require 'cloud/queue/response'
require 'convert_util'
require 'image'

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
      result = self.convert_slide(obj['key'])
      if result
        SlideHub::BatchLogger.info("Delete message from Queue. id=#{obj['id']} key=#{obj['key']}")
        CloudConfig::SERVICE.delete_message(msg)
      else
        SlideHub::BatchLogger.error("Slide conversion failed. id=#{obj['id']} key=#{obj['key']}")
      end
    end
  end

  def self.convert_slide(key)
    require 'tmpdir'
    Dir.mktmpdir do |dir|
      SlideHub::BatchLogger.info("Current directory is #{dir}")
      file = SecureRandom.hex.to_s
      CloudConfig::SERVICE.save_file(CloudConfig::SERVICE.config.bucket_name, key, "#{dir}/#{file}")
      ft = SlideHub::ConvertUtil.new.get_slide_file_type("#{dir}/#{file}")
      SlideHub::BatchLogger.info("File Type is #{ft}")
      case ft
      when 'pdf'
        SlideHub::BatchLogger.info('Rename to PDF')
        SlideHub::ConvertUtil.new.rename_to_pdf(dir, file)
        SlideHub::BatchLogger.info('Start converting from PDF to PPM')
        SlideHub::ConvertUtil.new.pdf_to_ppm(dir, "#{file}.pdf")
      when 'ppt', 'pptx'
        SlideHub::BatchLogger.info('Start converting from PPT to PDF')
        SlideHub::ConvertUtil.new.ppt_to_pdf(dir, file)
        SlideHub::BatchLogger.info(SlideHub::ConvertUtil.new.get_local_file_list(dir, '').inspect)
        SlideHub::BatchLogger.info('Start converting from PDF to PPM')
        SlideHub::ConvertUtil.new.pdf_to_ppm(dir, "#{file}.pdf")
        SlideHub::BatchLogger.info(SlideHub::ConvertUtil.new.get_local_file_list(dir, '').inspect)
      else
        false
      end
      SlideHub::BatchLogger.info('Start converting from PPM to JPG')
      slide_image_list = SlideHub::ConvertUtil.new.ppm_to_jpg(dir)
      SlideHub::BatchLogger.info(SlideHub::ConvertUtil.new.get_local_file_list(dir, '').inspect)
      final_list = slide_image_list.dup

      self.generate_json_list(slide_image_list, key, "#{dir}/list.json")
      final_list.push("#{dir}/list.json")

      SlideHub::BatchLogger.info('Generating thumbnails')
      SlideHub::BatchLogger.info(slide_image_list.inspect)
      thumbnail_list = SlideHub::ConvertUtil.new.jpg_to_thumbnail(slide_image_list)
      thumbnail_list.each do |tm|
        final_list.push(tm)
      end if thumbnail_list.instance_of?(Array)

      transcript = SlideHub::ConvertUtil.new.pdf_to_transcript(dir, "#{file}.pdf")
      final_list.push(transcript) if transcript

      SlideHub::BatchLogger.info(final_list.inspect)
      CloudConfig::SERVICE.upload_files(CloudConfig::SERVICE.config.image_bucket_name, final_list, key)

      slide = Slide.where('slides.key = ?', key).first
      slide.convert_status = 100
      slide.extension = ".#{ft}"
      slide.num_of_pages = slide_image_list.count
      slide.save
      true
    end
  end

  def self.generate_json_list(list, prefix, filename)
    save_list = []
    list.each do |item|
      save_list.push("#{prefix}/#{File.basename(item)}")
    end
    open(filename, 'w') do |io|
      JSON.dump(save_list, io)
    end
  end
end
