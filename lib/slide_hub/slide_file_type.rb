module SlideHub
  # 変換するファイル（拡張子なし）の中身を見て、変換できる形式かを見分ける
  module SlideFileType
    PPTX = 'application/vnd.openxmlformats-officedocument.presentationml.presentation'.freeze

    # PowerPoint 97-2003 のファイルには「PowerPoint Document」という名前の中身（ストリーム）がある。
    # 入れ物（OLE）は Word や Excel と同じなので、この名前で見分ける。名前は UTF-16LE で書かれている
    POWERPOINT_STREAM_NAME = 'PowerPoint Document'.encode('UTF-16LE').b.freeze
    CHUNK_SIZE = 1024 * 1024

    module_function

    # 'pdf'・'ppt'・'pptx' のどれか。変換できない形式なら false
    def detect(file)
      case File.open(file, 'rb') { |io| Marcel::MimeType.for(io) }
      when 'application/pdf' then 'pdf'
      when PPTX then 'pptx'
      when 'application/x-ole-storage', 'application/vnd.ms-powerpoint'
        powerpoint_97?(file) ? 'ppt' : false
      else
        false
      end
    end

    # 少しずつ読む。名前が読み込みの切れ目をまたいでも見つかるよう、前の残りをつなげて探す
    def powerpoint_97?(file)
      overlap = POWERPOINT_STREAM_NAME.bytesize - 1
      File.open(file, 'rb') do |io|
        rest = ''.b
        while (chunk = io.read(CHUNK_SIZE))
          data = rest + chunk
          return true if data.include?(POWERPOINT_STREAM_NAME)

          rest = data.byteslice(-overlap, overlap) || data
        end
      end
      false
    end
  end
end
