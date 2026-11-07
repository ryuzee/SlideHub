module SlideHub
  # ログインの記憶期間（Devise.remember_for）より前から使われていないセッションを消す。
  # 以前はページを開くたびに消していたが、変換バッチ（1 分ごと）で行えば十分なので、ここに移した
  class SessionCleanup
    def self.run(logger)
      deleted = ActiveRecord::SessionStore::Session.where(updated_at: ...Devise.remember_for.ago).delete_all
      logger.info("Deleted #{deleted} old sessions") if deleted.positive?
      deleted
    rescue StandardError => e
      # 消せなくても変換は続ける
      logger.error("Failed to delete old sessions: #{e.message}")
      0
    end
  end
end
