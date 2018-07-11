require 'open3'

module SlideHub
  class ConvertUtil
    attr_reader :logger

    def initialize(current_logger)
      @logger = current_logger
    end

    def rename_to_pdf(dir, file)
      cmd = "cd #{dir} && mv #{file} #{file}.pdf"
      result = exec_command(cmd)
      result
    end

    def pdf_to_ppm(dir, file)
      cmd = "cd #{dir} && pdftoppm #{file} slide"
      result = exec_command(cmd)
      result
    end

    def ppt_to_pdf(dir, file)
      cmd = "cd #{dir} && unoconv -f pdf -o #{file}.pdf #{file}"
      result = exec_command(cmd)
      result
    end

    def ppm_to_jpg(dir)
      cmd = "cd #{dir} && mogrify -format jpg slide*.ppm"
      result = exec_command(cmd)
      if result
        list = self.get_local_file_list(dir, '.jpg')
        list
      else
        false
      end
    end

    def jpg_to_thumbnail(list)
      i = SlideHub::Image.new
      thumbnail_list = []

      save_to = "#{File.dirname(list[0])}/thumbnail.jpg"
      i.thumbnail(list[0], save_to)
      thumbnail_list.push(save_to)

      list.each do |f|
        save_to = "#{File.dirname(f)}/#{File.basename(f, '.jpg')}-small.jpg"
        i.thumbnail(f, save_to)
        thumbnail_list.push(save_to)
      end
      thumbnail_list
    end

    def pdf_to_transcript(dir, file)
      transcript = []
      reader = PDF::Reader.new("#{dir}/#{file}")
      page_count = reader.page_count.to_i
      page_count.times do |i|
        current_page = i + 1
        cmd = "cd #{dir} && pdftotext #{file} -f #{current_page} -l #{current_page} - > #{dir}/#{current_page}.txt"
        result = exec_command(cmd)
        if result && File.exist?("#{dir}/#{current_page}.txt")
          str = File.read("#{dir}/#{current_page}.txt")
          str.gsub!(/([\r|\n|\t| |　|\u{2028}]+)/, ' ')
        else
          str = ''
        end
        transcript.push(str)
      end
      require 'php_serialization/serializer'
      File.write("#{dir}/transcript.txt", PhpSerialization::Serializer.new.run(transcript))
      "#{dir}/transcript.txt"
    end

    def get_slide_file_type(file)
      ext = FileMagic.new(FileMagic::MAGIC_MIME).file(file).split(';').first
      case ext
      when 'application/pdf'
        'pdf'
      when 'application/vnd.ms-powerpoint'
        'ppt'
      when 'application/vnd.openxmlformats-officedocument.presentationml.presentation'
        'pptx'
      else
        false
      end
    end

    def get_local_file_list(dir, extension)
      list = []
      Dir.glob("#{dir}/*#{extension}").each do |f|
        list.push(f)
      end
      list.sort
    end

    private

      def exec_command(cmd)
        logger.info(cmd)
        Open3.popen3(cmd) do |_i, o, e, w|
          out = o.read
          err = e.read
          logger.info out unless out.empty?
          logger.error err unless err.empty?
          return w.value.exitstatus.zero?
        end
      rescue StandardError => e
        logger.error(e.to_s)
        false
      end
  end
end
