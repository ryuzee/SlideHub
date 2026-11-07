# CSS・JavaScript などを配るときの、圧縮とブラウザのキャッシュ。
#
# - 圧縮：Rack::Deflater で、文字のファイル（HTML・CSS・JavaScript・JSON など）を gzip で送る。
#   スライドのダウンロードや画像のような、もともと圧縮されているものは対象にしない
# - キャッシュ：ファイル名に中身の指紋（-1a2b3c4d）が入った /assets/ のファイルは、
#   中身が変わればファイル名も変わるので、1 年間そのまま使ってもらう（immutable）。
#   それ以外の public のファイル（テーマの画像やアイコンなど）は config.public_file_server.headers に従う
module SlideHub
  class FingerprintedAssetCache
    CACHE_CONTROL = 'public, max-age=31536000, immutable'.freeze
    FINGERPRINTED = %r{\A/assets/.+-[0-9a-f]{8,}\.[a-z0-9]+(\.map)?\z}

    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)
      headers['cache-control'] = CACHE_CONTROL if [200, 304].include?(status) && FINGERPRINTED.match?(env['PATH_INFO'].to_s)
      [status, headers, body]
    end
  end
end

COMPRESSIBLE_TYPES = %w[
  text/html text/css text/javascript text/plain text/xml
  application/javascript application/json application/xml application/rss+xml image/svg+xml
].freeze

Rails.application.config.middleware.insert_before ActionDispatch::Static, Rack::Deflater, include: COMPRESSIBLE_TYPES
Rails.application.config.middleware.insert_before ActionDispatch::Static, SlideHub::FingerprintedAssetCache
