require 'open3'

module SlideHub
  class ConvertUtil
    attr_reader :logger

    def initialize(current_logger)
      @logger = current_logger
    end

    def rename_to_pdf(dir, file)
      cmd = "cd #{dir} && mv #{file} #{file}.pdf"
      exec_command(cmd)
    end

    def pdf_to_ppm(dir, file)
      cmd = "cd #{dir} && pdftoppm #{file} slide"
      exec_command(cmd)
    end

    def ppt_to_pdf(dir, file)
      cmd = "cd #{dir} && unoconv -f pdf -o #{file}.pdf #{file}"
      exec_command(cmd)
    end

    def pdf_to_jpg(dir, file)
      # 歴史的経緯で、過去のツールでは0埋め連番だったのを再現する
      width = self.class.page_number_width(pdf_page_count(dir, file))
      cmd = "cd #{dir} && mutool draw -o slide-%0#{width}d.jpg -r 120 #{file}.pdf"
      result = exec_command(cmd)
      if result
        self.get_local_file_list(dir, '.jpg')

      else
        false
      end
    end

    # ページ番号の0埋めの桁数。表示側 (SlidePages#list) と同じく、ページ数の桁数にする。
    # 以前は Math.log10(ページ数).ceil で、10・100・1000 ページちょうどのとき1桁足りなかった
    def self.page_number_width(page_count)
      page_count.abs.to_s.length
    end

    def pdf_page_count(dir, file)
      `cd #{dir} && mutool info #{file}.pdf | grep Pages | awk '{print $2}'`.to_i
    end

    def jpg_to_thumbnail(list)
      slidehub_image = SlideHub::Image.new
      thumbnail_list = slidehub_image.list_thumbnails(list[0])

      save_to = "#{File.dirname(list[0])}/thumbnail-middle.jpg"
      slidehub_image.shrink(list[0], save_to)
      thumbnail_list.push(save_to)

      list.each do |file|
        save_to = "#{File.dirname(file)}/#{File.basename(file, '.jpg')}-small.jpg"
        slidehub_image.thumbnail(file, save_to)
        thumbnail_list.push(save_to)
      end
      thumbnail_list
    end

    def pdf_to_transcript(dir, file)
      transcript = []
      reader = PDF::Reader.new("#{dir}/#{file}")
      page_count = reader.page_count.to_i
      page_count.times do |index|
        current_page = index + 1
        cmd = "cd #{dir} && pdftotext #{file} -f #{current_page} -l #{current_page} - > #{dir}/#{current_page}.txt"
        result = exec_command(cmd)
        if result && File.exist?("#{dir}/#{current_page}.txt")
          str = File.read("#{dir}/#{current_page}.txt")
          str.gsub!(/([\r|\n\t 　\u{2028}]+)/, ' ')
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
      Dir.glob("#{dir}/*#{extension}").each do |file|
        list.push(file)
      end
      list.sort
    end

    private

      # :reek:UncommunicativeVariableName
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
