module SlideHub
  # 変換するファイル（拡張子なし）の中身を見て、変換できる形式かを見分ける。
  # 受け付けるのは PDF だけ（PowerPoint は 3.0.10 で受け付けをやめた）
  module SlideFileType
    module_function

    # 'pdf'。変換できない形式なら false
    def detect(file)
      File.open(file, 'rb') { |io| Marcel::MimeType.for(io) } == 'application/pdf' ? 'pdf' : false
    end
  end
end
