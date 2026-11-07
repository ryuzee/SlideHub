require 'rails_helper'

RSpec.describe SlideHub::ConvertProcedure do
  let(:logger) { instance_double(Logger, info: nil, error: nil) }
  let(:provider) { CloudConfig.provider }

  # 変換そのもの（ダウンロード、画像化、アップロード）は止めて、キーの扱いと後片付けだけを確かめる
  def build(**keys)
    procedure = described_class.new(logger: logger, **keys)
    %i[save_file convert_to_jpg generate_json convert_to_thumbnail convert_to_transcript upload_files].each do |step|
      allow(procedure).to receive(step).and_return(true)
    end
    procedure
  end

  before do
    allow(provider).to receive(:delete_slide).and_return(true)
    allow(provider).to receive(:delete_generated_files).and_return(true)
  end

  it 'converts in place and deletes nothing when no other key is given' do
    slide = create(:slide)
    expect(provider).not_to receive(:copy_slide)
    expect(provider).not_to receive(:delete_slide)
    expect(build(object_key: slide.object_key).run).to be(true)
    expect(Slide.find(slide.id).object_key).to eq(slide.object_key)
  end

  it 'deletes the previous key after converting a replaced file' do
    slide = create(:slide)
    expect(provider).to receive(:delete_slide).with('oldkey')
    expect(provider).to receive(:delete_generated_files).with('oldkey')
    build(object_key: slide.object_key, previous_object_key: 'oldkey').run
    expect(Slide.find(slide.id)).to be_converted
  end

  it 'moves a reconverted slide to the new key and deletes the old one' do
    slide = create(:slide)
    old_key = slide.object_key
    expect(provider).to receive(:copy_slide).with(old_key, 'newkey').and_return(true)
    expect(provider).to receive(:delete_slide).with(old_key)
    expect(provider).to receive(:delete_generated_files).with(old_key)
    build(object_key: old_key, new_object_key: 'newkey').run
    expect(Slide.find(slide.id).object_key).to eq('newkey')
  end

  it 'keeps the files of a key that another slide still uses' do
    slide = create(:slide)
    other = create(:slide, object_key: 'sharedkey')
    expect(provider).not_to receive(:delete_slide)
    build(object_key: slide.object_key, previous_object_key: other.object_key).run
  end

  it 'marks the slide as a conversion error when the file is not a PDF' do
    slide = create(:slide)
    procedure = described_class.new(object_key: slide.object_key, logger: logger)
    allow(procedure).to receive(:save_file) { procedure.instance_variable_set(:@file_type, 'txt') }
    expect(procedure).not_to receive(:upload_files)
    expect(logger).to receive(:error).with(/Unsupported file type/)
    expect(procedure.run).to be(true)
    expect(Slide.find(slide.id)).to be_convert_error
  end

  it 'still succeeds when deleting the old files fails' do
    slide = create(:slide)
    allow(provider).to receive(:delete_slide).and_raise(StandardError, 'boom')
    expect(logger).to receive(:error).with(/boom/)
    expect(build(object_key: slide.object_key, previous_object_key: 'oldkey').run).to be(true)
  end

  describe 'with the real conversion steps' do
    # 保存先のクラウドだけを差し替え、ダウンロードの代わりにテスト用の PDF を置く
    it 'converts a PDF into page images, thumbnails, a page list and text, then marks the slide as converted' do
      slide = create(:slide, convert_status: :unconverted, num_of_pages: 0)
      fixture = Rails.root.join('spec/fixtures/files/two_pages.pdf')
      allow(provider).to receive(:save_file) do |_bucket, _key, destination|
        FileUtils.cp(fixture, destination)
        true
      end
      allow(provider).to receive(:copy_slide)
      uploaded = nil
      list_json = nil
      allow(provider).to receive(:upload_files) do |bucket, files, prefix|
        uploaded = { bucket: bucket, prefix: prefix, names: files.map { |path| File.basename(path) } }
        list_json = JSON.parse(File.read(files.find { |path| path.end_with?('list.json') }))
      end

      expect(described_class.new(object_key: slide.object_key, new_object_key: 'newkey', logger: logger).run).to be(true)

      expect(uploaded[:prefix]).to eq('newkey')
      expect(uploaded[:names]).to include('slide-1.jpg', 'slide-2.jpg', 'slide-1-small.jpg', 'thumbnail.jpg',
                                          'thumbnail-16x9.jpg', 'thumbnail-middle.jpg', 'transcript.txt', 'list.json')
      expect(list_json).to eq(%w[newkey/slide-1.jpg newkey/slide-2.jpg])
      saved = Slide.find(slide.id)
      expect([saved.object_key, saved.convert_status, saved.num_of_pages, saved.extension]).to eq(['newkey', 'converted', 2, '.pdf'])
    end
  end
end
