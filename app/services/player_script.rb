# プレイヤーの JavaScript（ページ送りなどの動き）を、読みにくくするために圧縮して返す。
#
# 圧縮（Uglifier）は 1 回に 1 秒近くかかるので、表示のたびには行わない。
# ページごとに変わる値（名前の接頭辞と開始ページ）を目印の名前のまま圧縮して覚えておき、
# 表示のたびには目印をそのページの値に差し替えるだけにする。
#
# 覚えておくのは、プレイヤーのテンプレートを描画した結果ごとに 1 つ。スライドの数には関係なく、
# 変わるのはサイトの URL（画像の URL に入る）とテンプレートの中身だけなので、ごく少数になる
class PlayerScript
  # テンプレートに入れておく目印。圧縮しても名前が変わらないよう、グローバルな名前にしてある
  START_INDEX = 'SLIDEHUB_START_INDEX'.freeze
  OBJECT_NAME = 'OSSJSPARTS'.freeze
  CSS_PREFIX = 'PREFIX'.freeze

  @minified = {}
  @mutex = Mutex.new

  class << self
    # template はテンプレートを目印のまま描画した JavaScript
    def build(template, prefix:, start_index:)
      minified(template).
        gsub(OBJECT_NAME, "#{OBJECT_NAME}#{prefix}").
        gsub(CSS_PREFIX, prefix).
        gsub(START_INDEX, start_index.to_s)
    end

    def minified(template)
      key = Digest::SHA256.hexdigest(template)
      @mutex.synchronize do
        @minified[key] ||= Uglifier.new(harmony: true).compile(template)
      end
    end

    # テスト用
    def clear
      @mutex.synchronize { @minified.clear }
    end
  end
end
