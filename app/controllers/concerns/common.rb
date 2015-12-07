require 'net/http'
require 'uri'
require 'json'
require 'securerandom'

module Common
  extend ActiveSupport::Concern

  def convert_slide(key)
    require 'tmpdir'
    Dir.mktmpdir do |dir|
      Oss::BatchLogger.info("Current directory is #{dir}")
      file = "#{SecureRandom.hex}"
      # @TODO:needs to be method and retry
      storage = Storage.new
      storage.save_file(ENV['OSS_BUCKET_NAME'], key, "#{dir}/#{file}")
      ft = Oss::ConvertUtil.new.get_slide_file_type("#{dir}/#{file}")
      Oss::BatchLogger.info("File Type is #{ft}")
      case ft
      when 'pdf'
        Oss::BatchLogger.info('Rename to PDF')
        Oss::ConvertUtil.new.rename_to_pdf(dir, file)
        Oss::BatchLogger.info('Start converting from PDF to PPM')
        Oss::ConvertUtil.new.pdf_to_ppm(dir, "#{file}.pdf")
      when 'ppt', 'pptx'
        Oss::BatchLogger.info('Start converting from PPT to PDF')
        Oss::ConvertUtil.new.ppt_to_pdf(dir, file)
        Oss::BatchLogger.info(Oss::ConvertUtil.new.get_local_file_list(dir, '').inspect)
        Oss::BatchLogger.info('Start converting from PDF to PPM')
        Oss::ConvertUtil.new.pdf_to_ppm(dir, "#{file}.pdf")
        Oss::BatchLogger.info(Oss::ConvertUtil.new.get_local_file_list(dir, '').inspect)
      else
        false
      end
      Oss::BatchLogger.info('Start converting from PPM to JPG')
      slide_image_list = Oss::ConvertUtil.new.ppm_to_jpg(dir)
      Oss::BatchLogger.info(Oss::ConvertUtil.new.get_local_file_list(dir, '').inspect)
      final_list = slide_image_list.dup

      self.generate_json_list(slide_image_list, key, "#{dir}/list.json")
      final_list.push("#{dir}/list.json")

      Oss::BatchLogger.info('Generating thumbnails')
      Oss::BatchLogger.info(slide_image_list.inspect)
      thumbnail_list = Oss::ConvertUtil.new.jpg_to_thumbnail(slide_image_list)
      thumbnail_list.each do |tm|
        final_list.push(tm)
      end if thumbnail_list.instance_of?(Array)

      transcript = Oss::ConvertUtil.new.pdf_to_transcript(dir, "#{file}.pdf")
      final_list.push(transcript) if transcript

      Oss::BatchLogger.info(final_list.inspect)
      storage = Storage.new
      storage.upload_files(ENV['OSS_IMAGE_BUCKET_NAME'], final_list, key)

      slide = Slide.where('slides.key = ?', key).first
      slide.convert_status = 100
      slide.save
      true
    end
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
end
