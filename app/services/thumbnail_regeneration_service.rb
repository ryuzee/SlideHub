# 変換済みスライドすべてについて、一覧用サムネイルの再生成をキューに積む。
# 実際の生成は変換バッチ (SlideHub::Batch → SlideHub::ThumbnailProcedure) が行う。
class ThumbnailRegenerationService
  MESSAGE_TYPE = 'thumbnail'.freeze

  def self.message_for(slide)
    { type: MESSAGE_TYPE, id: slide.id, object_key: slide.object_key }.to_json
  end

  # キューに積んだスライド数を返す
  def request_all
    count = 0
    Slide.converted.find_each do |slide|
      CloudConfig.provider.send_message(self.class.message_for(slide))
      count += 1
    end
    count
  end
end
