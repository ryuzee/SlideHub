require 'tmpdir'

module SlideHub
  # 変換済みスライドの一覧用サムネイル（4:3 / 16:9）だけを作り直す。
  # スライド本体は変換し直さず、画像バケットにある1ページ目の画像から作る。
  # 管理画面の「サムネイルを一括再生成」からキュー経由で呼ばれる（SlideHub::Batch）。
  class ThumbnailProcedure
    def initialize(object_key:, logger:)
      @object_key = object_key
      @logger = logger
    end

    def run
      first_page = first_page_key
      unless first_page
        logger.error("No page image found. object_key=#{object_key}")
        return false
      end

      Dir.mktmpdir do |dir|
        local_file = "#{dir}/#{File.basename(first_page)}"
        return false unless provider.save_file(provider.config.image_bucket_name, first_page, local_file)

        thumbnails = SlideHub::Image.new.list_thumbnails(local_file)
        provider.upload_files(provider.config.image_bucket_name, thumbnails, object_key)
        logger.info("Regenerated thumbnails. object_key=#{object_key}")
        true
      end
    end

    private

      attr_reader :object_key, :logger

      def provider
        CloudConfig.provider
      end

      # ページ画像は slide-1.jpg / slide-01.webp のように、桁数と形式がスライドごとに違うので、
      # 一覧から slide-<数字>.jpg か .webp を探して番号が最小のものを1ページ目とする。
      # サムネイルは1ページ目と同じ形式で作る
      PAGE_IMAGE = %r{/slide-(\d+)\.(?:jpg|webp)\z}

      def first_page_key
        keys = provider.get_file_list(provider.config.image_bucket_name, "#{object_key}/slide-").map { |file| file[:key] }
        keys.grep(PAGE_IMAGE).min_by { |key| key[PAGE_IMAGE, 1].to_i }
      end
  end
end
