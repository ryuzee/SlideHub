require 'rails_helper'

RSpec.describe SlideHub::Image do
  let(:image) { described_class.new }

  around do |example|
    Dir.mktmpdir do |dir|
      @dir = dir
      example.run
    end
  end

  def make_jpg(name, width, height)
    path = File.join(@dir, name)
    Magick::Image.new(width, height) { |options| options.background_color = '#336699' }.write(path)
    path
  end

  def size_of(path)
    img = Magick::Image.ping(path).first
    [img.columns, img.rows]
  end

  describe '#thumbnail' do
    it 'shrinks and crops a large image to fill 320x240' do
      src = make_jpg('large.jpg', 1600, 900)
      image.thumbnail(src, File.join(@dir, 'out.jpg'))
      expect(size_of(File.join(@dir, 'out.jpg'))).to eq([320, 240])
    end

    it 'puts a small image in the middle of a white 320x240 image' do
      src = make_jpg('small.jpg', 100, 50)
      dest = File.join(@dir, 'out.jpg')
      image.thumbnail(src, dest)
      expect(size_of(dest)).to eq([320, 240])
      corner = Magick::Image.read(dest).first.pixel_color(0, 0)
      # 色の深さ（8 ビットか 16 ビットか）は ImageMagick のビルドによるので、最大値との比で見る
      expect([corner.red, corner.green, corner.blue].map { |c| c.to_f / Magick::QuantumRange }).to all(be >= 0.98)
    end
  end

  describe '#shrink' do
    it 'shrinks a wide image to 1200 pixels wide, keeping its shape' do
      src = make_jpg('wide.jpg', 2400, 1800)
      image.shrink(src, File.join(@dir, 'out.jpg'))
      expect(size_of(File.join(@dir, 'out.jpg'))).to eq([1200, 900])
    end

    it 'keeps an image that is already small enough' do
      src = make_jpg('narrow.jpg', 800, 600)
      image.shrink(src, File.join(@dir, 'out.jpg'))
      expect(size_of(File.join(@dir, 'out.jpg'))).to eq([800, 600])
    end
  end

  describe '#page_image' do
    it 'saves a PNG page as a real WebP image' do
      src = make_jpg('slide-1.png', 1600, 900)
      dest = File.join(@dir, 'slide-1.webp')
      image.page_image(src, dest)
      expect(Magick::Image.ping(dest).first.format).to eq('WEBP')
      expect(size_of(dest)).to eq([1600, 900])
    end

    it 'shrinks a page wider than 2560 pixels, keeping the aspect ratio' do
      src = make_jpg('slide-1.png', 3200, 1800)
      dest = File.join(@dir, 'slide-1.webp')
      image.page_image(src, dest)
      expect(size_of(dest)).to eq([2560, 1440])
    end
  end

  describe '#list_thumbnails' do
    it 'makes the thumbnails in the same format as the first page' do
      made = image.list_thumbnails(make_jpg('slide-1.jpg', 1280, 720)).map { |path| File.basename(path) }
      expect(made).to eq(%w[thumbnail.jpg thumbnail-16x9.jpg])
    end
  end
end
