require 'open3'
require 'fileutils'

module SlideHub
  class ConvertUtil
    attr_reader :logger

    def initialize(current_logger)
      @logger = current_logger
    end

    # 外部コマンドは、シェルを通さずに引数の配列で実行する（dir を作業フォルダにする）

    def rename_to_pdf(dir, file)
      FileUtils.mv(File.join(dir, file), File.join(dir, "#{file}.pdf"))
      true
    rescue StandardError => e
      logger.error(e.to_s)
      false
    end

    def pdf_to_ppm(dir, file)
      exec_command('pdftoppm', file, 'slide', chdir: dir)
    end

    def ppt_to_pdf(dir, file)
      exec_command('unoconv', '-f', 'pdf', '-o', "#{file}.pdf", file, chdir: dir)
    end

    def pdf_to_jpg(dir, file)
      # 歴史的経緯で、過去のツールでは0埋め連番だったのを再現する
      width = self.class.page_number_width(pdf_page_count(dir, file))
      result = exec_command('mutool', 'draw', '-o', "slide-%0#{width}d.jpg", '-r', '120', "#{file}.pdf", chdir: dir)
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

    # mutool info の出力の「Pages: 48」の行から、ページ数を取り出す
    def pdf_page_count(dir, file)
      out, _err, _status = Open3.capture3('mutool', 'info', "#{file}.pdf", chdir: dir)
      out[/^Pages:\s*(\d+)/, 1].to_i
    rescue StandardError => e
      logger.error(e.to_s)
      0
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
        result = exec_command('pdftotext', file, '-f', current_page.to_s, '-l', current_page.to_s, "#{current_page}.txt", chdir: dir)
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

      # コマンドと引数を分けて渡すので、シェルは通らない
      def exec_command(*command, chdir:)
        logger.info("#{command.join(' ')} (in #{chdir})")
        out, err, status = Open3.capture3(*command, chdir: chdir)
        logger.info out unless out.empty?
        logger.error err unless err.empty?
        status.success?
      rescue StandardError => e
        logger.error(e.to_s)
        false
      end
  end
end
