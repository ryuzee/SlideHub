# スライドの一括再変換のおおよその進捗。サムネイル一括再生成と同じく、キューの残りから推定する。
# キューにはほかの処理のメッセージも入るので、まだ WebP になっていないスライドの数より多くは数えない。
# 元のファイルが無いスライドは WebP にならないが、メッセージは消えるので、キューが空になれば終わったと分かる
class BulkReconversionProgress < ThumbnailRegenerationProgress
  REQUESTED_AT_KEY = 'bulk_reconversion.requested_at'.freeze
  REQUESTED_COUNT_KEY = 'bulk_reconversion.requested_count'.freeze
  FINISHED_AT_KEY = 'bulk_reconversion.finished_at'.freeze

  # まだ1件も進んでいないときに使う処理速度（件/秒）。
  # 再変換は 1 件に 20〜30 秒かかるので、1 回に 5 件を処理すると、60 秒の待ちと合わせて約 3 分になる
  DEFAULT_RATE = 5.0 / 185

  def initialize(target_count: BulkReconversionService.targets.count, **)
    super(**)
    @target_count = target_count
  end

  def remaining
    value = super
    value && [value, @target_count].min
  end
end
