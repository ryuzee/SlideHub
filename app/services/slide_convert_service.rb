# 変換を頼むメッセージをキューに送る
class SlideConvertService
  def initialize(slide)
    @slide = slide
  end

  # 新しく上げたファイルの変換。previous_object_key を渡すと（ファイルの差し替え）、
  # 変換が終わったあとに古いキーのファイルを消す
  def send_request(previous_object_key: nil)
    message = { id: @slide.id, object_key: @slide.object_key }
    message[:previous_object_key] = previous_object_key if previous_object_key.present?
    CloudConfig.provider.send_message(message.to_json)
  end

  # 今のファイルの再変換。結果は新しいキーに置き、変換が終わってからスライドをそちらに切り替える。
  # 変換が終わるまでは、今の画像がそのまま表示される
  def send_reconvert_request
    message = { id: @slide.id, object_key: @slide.object_key, new_object_key: Slide.generate_object_key }
    CloudConfig.provider.send_message(message.to_json)
  end
end
