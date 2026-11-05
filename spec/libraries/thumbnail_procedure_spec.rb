require 'rails_helper'

RSpec.describe SlideHub::ThumbnailProcedure do
  let(:logger) { instance_double(Logger, info: nil, error: nil) }
  let(:provider) { CloudConfig.provider }

  def write_image(path, width, height)
    Magick::Image.new(width, height).write(path)
  end

  it 'regenerates 4:3 and 16:9 thumbnails from the first page image' do
    allow(provider).to receive(:get_file_list).and_return(
      [{ key: 'abc/slide-10.jpg' }, { key: 'abc/slide-2.jpg' }, { key: 'abc/slide-1-small.jpg' }, { key: 'abc/slide-1.jpg' }],
    )
    allow(provider).to receive(:save_file) do |_bucket, key, destination|
      expect(key).to eq('abc/slide-1.jpg')
      write_image(destination, 1280, 720)
      true
    end
    uploaded = {}
    allow(provider).to receive(:upload_files) do |_bucket, files, prefix|
      expect(prefix).to eq('abc')
      files.each do |file|
        image = Magick::Image.read(file).first
        uploaded[File.basename(file)] = [image.columns, image.rows]
      end
    end

    expect(described_class.new(object_key: 'abc', logger: logger).run).to be(true)
    expect(uploaded).to eq('thumbnail.jpg' => [320, 240], 'thumbnail-16x9.jpg' => [480, 270])
  end

  it 'fails when there is no page image' do
    allow(provider).to receive(:get_file_list).and_return([])
    expect(provider).not_to receive(:upload_files)
    expect(described_class.new(object_key: 'abc', logger: logger).run).to be(false)
  end
end
