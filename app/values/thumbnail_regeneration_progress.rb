# サムネイル一括再生成のおおよその進捗。
# 進捗はキューに残っているメッセージ数から推定するので概算（スライドの変換待ちも件数に含まれる）。
# スライドの一括再変換の進捗（BulkReconversionProgress）も、この仕組みを使う。
# 子クラスで定数（記録する設定のキーと既定の処理速度）を変えられるよう、定数は self.class:: で読む
class ThumbnailRegenerationProgress
  REQUESTED_AT_KEY = 'thumbnail_regeneration.requested_at'.freeze
  REQUESTED_COUNT_KEY = 'thumbnail_regeneration.requested_count'.freeze
  # 一度終わったら記録する。あとで別の処理でキューが増えても、終わった進捗が戻らないようにする
  FINISHED_AT_KEY = 'thumbnail_regeneration.finished_at'.freeze

  # まだ1件も進んでいないときに使う処理速度（件/秒）。
  # 変換バッチは1回に最大5件を処理し、60秒待ってから次を処理する（script/oss_docker_batchjob.sh）
  DEFAULT_RATE = 5.0 / 70

  def self.record(count, now: Time.current)
    ApplicationSetting[self::REQUESTED_AT_KEY] = now.iso8601
    ApplicationSetting[self::REQUESTED_COUNT_KEY] = count.to_s
    ApplicationSetting[self::FINISHED_AT_KEY] = ''
  end

  def initialize(now: Time.current, queue_length: CloudConfig.provider.queue_length)
    @now = now
    @queue_length = queue_length
  end

  def requested?
    requested_at.present? && requested_count.positive?
  end

  def requested_at
    value = ApplicationSetting[self.class::REQUESTED_AT_KEY]
    Time.zone.parse(value) if value.present?
  end

  def requested_count
    ApplicationSetting[self.class::REQUESTED_COUNT_KEY].to_i
  end

  # キューに残っている件数。取得できなかったときは nil
  attr_reader :queue_length

  # SQS のキューの件数は概算で、メッセージを入れてからしばらくは 0 と返ることがある。
  # 頼んでからこの秒数のあいだは、キューが少なく見えても、まだ何も終わっていないとみなす
  JUST_REQUESTED_SECONDS = 120

  def remaining
    return 0 if finished_before?
    return nil if queue_length.nil?
    return requested_count if just_requested?

    [queue_length, requested_count].min
  end

  def just_requested?
    requested? && @now - requested_at < JUST_REQUESTED_SECONDS
  end

  def done
    return nil if remaining.nil?

    requested_count - remaining
  end

  def finished?
    remaining&.zero? || false
  end

  # 終わっていれば、そのことを記録する（進捗を取りに来たときに呼ぶ）
  def remember_finish
    return unless requested? && finished? && !finished_before?

    ApplicationSetting[self.class::FINISHED_AT_KEY] = @now.iso8601
  end

  def finished_before?
    ApplicationSetting[self.class::FINISHED_AT_KEY].present?
  end

  # 推定残り時間（秒）。進んだ件数と経過時間から速度を出し、まだ進んでいなければ既定の速度を使う
  def estimated_seconds
    return nil if remaining.nil?
    return 0 if finished?

    (remaining / rate).ceil
  end

  def as_json(*)
    {
      requested: requested?,
      requested_at: requested_at&.iso8601,
      requested_count: requested_count,
      queue_length: queue_length,
      done: done,
      remaining: remaining,
      finished: finished?,
      estimated_seconds: estimated_seconds,
    }
  end

  private

    # 終わった件数が少ないうちは、測った速度がぶれやすいので、バッチの既定の速度を使う
    MIN_DONE_FOR_RATE = 5

    def rate
      elapsed = @now - requested_at
      return self.class::DEFAULT_RATE unless done.to_i >= MIN_DONE_FOR_RATE && elapsed.positive?

      done / elapsed
    end
end
