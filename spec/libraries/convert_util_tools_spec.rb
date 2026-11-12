require 'rails_helper'

# 本物のコマンド（mutool、pdftotext）と ImageMagick を使って、変換の各段階を確かめる
RSpec.describe SlideHub::ConvertUtil do
  let(:logger) { instance_double(Logger, info: nil, error: nil) }
  let(:util) { described_class.new(logger) }
  let(:fixture) { Rails.root.join('spec/fixtures/files/two_pages.pdf') }

  # 変換の作業フォルダに、ダウンロード直後と同じ「拡張子なしのファイル」を置く
  around do |example|
    Dir.mktmpdir do |dir|
      @dir = dir
      FileUtils.cp(fixture, File.join(dir, 'work'))
      example.run
    end
  end

  it 'recognizes a PDF and rejects other files' do
    expect(util.get_slide_file_type(File.join(@dir, 'work'))).to eq('pdf')
    expect(util.get_slide_file_type(Rails.root.join('spec/fixtures/dummy.txt').to_s)).to be(false)
  end

  # PowerPoint は受け付けない（3.0.10 でやめた）
  it 'rejects a PowerPoint file' do
    FileUtils.cp(Rails.root.join('spec/fixtures/files/one_page.pptx'), File.join(@dir, 'office'))
    expect(util.get_slide_file_type(File.join(@dir, 'office'))).to be(false)
  end

  it 'makes one image per page with the same numbering as SlidePages' do
    expect(util.rename_to_pdf(@dir, 'work')).to be(true)
    expect(util.pdf_page_count(@dir, 'work')).to eq(2)
    images = util.pdf_to_images(@dir, 'work')
    expect(images.map { |path| File.basename(path) }).to eq(%w[slide-1.webp slide-2.webp])
    expect(SlidePages.new('key', 2, 'webp').list).to eq(%w[key/slide-1.webp key/slide-2.webp])
    # 名前だけでなく、中身も WebP にする（mutool は .jpg と付けても PNG で書き出していた）
    expect(Magick::Image.ping(images.first).first.format).to eq('WEBP')
  end

  it 'extracts the text of each page' do
    util.rename_to_pdf(@dir, 'work')
    path = util.pdf_to_transcript(@dir, 'work.pdf')
    require 'php_serialization/unserializer'
    lines = PhpSerialization::Unserializer.new.run(File.read(path))
    expect(lines.map(&:strip)).to eq(['First page text', 'Second page text'])
  end

  it 'makes the list thumbnails and the middle-sized image in the same format as the pages' do
    util.rename_to_pdf(@dir, 'work')
    images = util.pdf_to_images(@dir, 'work')
    made = util.make_thumbnails(images).map { |path| File.basename(path) }
    expect(made).to contain_exactly('thumbnail.webp', 'thumbnail-16x9.webp', 'thumbnail-middle.webp')
    size = ->(name) { Magick::Image.ping(File.join(@dir, name)).first.then { |img| [img.columns, img.rows, img.format] } }
    expect(size.call('thumbnail.webp')).to eq([320, 240, 'WEBP'])
    expect(size.call('thumbnail-16x9.webp')).to eq([480, 270, 'WEBP'])
  end
end
