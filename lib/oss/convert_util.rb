module Oss
  class ConvertUtil
    def rename_to_pdf (dir, file)
      cmd = "cd #{dir} && mv #{file} #{file}.pdf"
      result = system(cmd)
      result
    end

    def pdf_to_ppm (dir, file)
      cmd = "cd #{dir} && pdftoppm #{file} slide"
      result = system(cmd)
      result
    end

    def ppt_to_pdf (dir, file)
      cmd = "cd #{dir} && unoconv -f pdf -o #{file}.pdf #{file}"
      result = system(cmd)
      result
    end

    def ppm_to_jpg (dir)
      cmd = "cd #{dir} && mogrify -format jpg slide*.ppm"
      result = system(cmd)
      if result
        list = self.get_local_file_list(dir, '.jpg')
        list
      else
        false
      end
    end

    def jpg_to_thumbnail (list)
      i = Oss::Image.new
      thumbnail_list = Array.new

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

    def pdf_to_transcript (dir, file)
      transcript = Array.new
      reader = PDF::Reader.new("#{dir}/#{file}")
      page_count = reader.page_count.to_i
      page_count.times do |i|
        current_page = i+1
        cmd = "cd #{dir} && pdftotext #{file} -f #{current_page} -l #{current_page} - > #{dir}/#{current_page}.txt"
        system(cmd)
        transcript.push(File.read("#{dir}/#{current_page}.txt").gsub(/([\r|\n|\t| |　]+)/," "))
      end
      require 'php_serialization/serializer'
      File.write("#{dir}/transcript.txt", PhpSerialization::Serializer.new.run(transcript))
      "#{dir}/transcript.txt"
    end

    def get_slide_file_type (file)
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

    def get_local_file_list (dir, extension)
      list = Array.new
      Dir::glob("#{dir}/*#{extension}").each {|f|
        list.push(f)
      }
      list.sort
    end
  end
end
