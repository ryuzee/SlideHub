# Origin ヘッダーの確認（forgery_protection_origin_check）を有効にする前に、本番で食い違いが出ないかを確かめる。
# 送信（GET 以外）の Origin ヘッダーがこのサイトの URL と違うときに、弾かずにログに残すだけにする。
# 確認が済んで forgery_protection_origin_check を有効にしたら、このモジュールは外す
module OriginCheckLogging
  extend ActiveSupport::Concern

  included do
    before_action :log_origin_mismatch, unless: -> { request.get? || request.head? }
  end

  private

    def log_origin_mismatch
      origin = request.origin
      return if origin.blank? || origin == request.base_url

      # 前段（CDN やロードバランサー）が何を渡しているかで直し方が変わるので、手がかりになるヘッダーも残す
      forwarded = %w[Host X-Forwarded-Host X-Forwarded-Proto X-Forwarded-Port X-Original-Host].
                  map { |name| "#{name}=#{request.headers[name].inspect}" }.join(' ')
      logger.warn("[OriginCheck] Origin #{origin.inspect} does not match #{request.base_url.inspect} " \
                  "(#{request.request_method} #{request.path}) #{forwarded}")
    end
end
