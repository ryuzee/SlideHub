# サムネイル一括再生成のおおよその進捗。
# 進捗はキューに残っているメッセージ数から推定するので概算（スライドの変換待ちも件数に含まれる）。
class ThumbnailRegenerationProgress
  REQUESTED_AT_KEY = 'thumbnail_regeneration.requested_at'.freeze
  REQUESTED_COUNT_KEY = 'thumbnail_regeneration.requested_count'.freeze

  # まだ1件も進んでいないときに使う処理速度（件/秒）。
  # 変換バッチは1回に最大5件を処理し、60秒待ってから次を処理する（script/oss_docker_batchjob.sh）
  DEFAULT_RATE = 5.0 / 70

  def self.record(count, now: Time.current)
    ApplicationSetting[REQUESTED_AT_KEY] = now.iso8601
    ApplicationSetting[REQUESTED_COUNT_KEY] = count.to_s
  end

  def initialize(now: Time.current, queue_length: CloudConfig.provider.queue_length)
    @now = now
    @queue_length = queue_length
  end

  def requested?
    requested_at.present? && requested_count.positive?
  end

  def requested_at
    value = ApplicationSetting[REQUESTED_AT_KEY]
    Time.zone.parse(value) if value.present?
  end

  def requested_count
    ApplicationSetting[REQUESTED_COUNT_KEY].to_i
  end

  # キューに残っている件数。取得できなかったときは nil
  attr_reader :queue_length

  def remaining
    return nil if queue_length.nil?

    [queue_length, requested_count].min
  end

  def done
    return nil if remaining.nil?

    requested_count - remaining
  end

  def finished?
    remaining&.zero? || false
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

    def rate
      elapsed = @now - requested_at
      return DEFAULT_RATE unless done.to_i.positive? && elapsed.positive?

      done / elapsed
    end
end
