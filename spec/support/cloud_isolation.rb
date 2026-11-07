# クラウドまわりの設定を、テストごとに元に戻す。
# 使うクラウド（CloudConfig.provider）、エンジンの設定（バケット名や CDN の URL）、
# AWS SDK の設定を書き換えるテストがあり、
# 戻さないと、あとに走るテストの URL や認証情報が変わってしまう
module CloudIsolation
  ENGINES = [SlideHub::Cloud::Engine::Aws, SlideHub::Cloud::Engine::Azure].freeze

  def self.snapshot
    {
      provider: CloudConfig.provider,
      engines: ENGINES.to_h { |engine| [engine, engine.config.config.to_h.dup] },
      aws: ::Aws.config.dup,
    }
  end

  def self.restore(saved)
    CloudConfig.provider = saved[:provider]
    saved[:engines].each do |engine, values|
      options = engine.config.config
      (options.keys - values.keys).each { |key| options.delete(key) }
      values.each { |key, value| options[key] = value }
    end
    ::Aws.config.replace(saved[:aws])
  end
end

RSpec.configure do |config|
  config.around do |example|
    saved = CloudIsolation.snapshot
    example.run
  ensure
    CloudIsolation.restore(saved)
  end

  # テスト用の画像バケットには、何も置かれていない（新しいスライドと同じ）。
  # ファイルの中身が要るテストは、自分で stub_request を用意する（あとから書いたものが優先される）
  config.before do
    # rails_helper の環境変数のバケットと、CloudHelpers が切り替えるバケット（S3 と Azure）
    test_image_storage = %r{\Ahttps?://(
      (test-image-bucket|my-image-bucket)\.s3[^/]*\.amazonaws\.com/ |
      [^/]+\.blob\.core\.windows\.net/(test-image-container|my-image-bucket)/
    )}x
    stub_request(:get, test_image_storage).to_return(status: 404)
  end
end
