# ページ画像が前の形式（jpg）のままの変換済みスライドを、まとめて再変換する（今の形式の WebP にする）。
# 実際の変換は変換バッチ (SlideHub::Batch → SlideHub::ConvertProcedure) が1件ずつ行い、
# 終わったスライドは image_format が変わるので、次に頼んだときは対象から外れる
class BulkReconversionService
  def self.targets
    Slide.converted.where.not(image_format: SlideHub::ConvertUtil::IMAGE_FORMAT)
  end

  # キューに積んだスライド数を返す
  def request_all
    count = 0
    self.class.targets.find_each do |slide|
      SlideConvertService.new(slide).send_reconvert_request
      count += 1
    end
    count
  end
end
