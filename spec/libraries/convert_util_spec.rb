require 'rails_helper'

RSpec.describe SlideHub::ConvertUtil do
  describe '.page_number_width' do
    it 'matches the zero padding that SlidePages uses to build page image names' do
      [1, 9, 10, 11, 99, 100, 101, 1000].each do |pages|
        expected_last = SlidePages.new('key', pages).list.last
        width = described_class.page_number_width(pages)
        expect("key/slide-#{pages.to_s.rjust(width, '0')}.jpg").to eq(expected_last)
      end
    end

    it 'returns one more digit than before for exactly 10, 100 and 1000 pages' do
      expect(described_class.page_number_width(10)).to eq(2)
      expect(described_class.page_number_width(100)).to eq(3)
      expect(described_class.page_number_width(1000)).to eq(4)
    end
  end

  describe 'running commands' do
    let(:logger) { instance_double(Logger, info: nil, error: nil) }
    let(:util) { described_class.new(logger) }
    let(:ok) { instance_double(Process::Status, success?: true) }

    it 'passes the command and its arguments separately, without a shell' do
      expect(Open3).to receive(:capture3).
        with('mutool', 'draw', '-o', 'slide-%01d.png', '-r', '120', 'work.pdf', chdir: '/tmp/x').
        and_return(['', '', ok])
      allow(util).to receive(:pdf_page_count).and_return(5)
      allow(util).to receive(:get_local_file_list).and_return(['/tmp/x/slide-1.png'])
      allow_any_instance_of(SlideHub::Image).to receive(:page_image)
      expect(util.pdf_to_images('/tmp/x', 'work')).to eq(['/tmp/x/slide-1.webp'])
    end

    it 'reads the page count from the output of mutool info' do
      allow(Open3).to receive(:capture3).and_return(["PDF-1.7\nPages: 48\nRetrieving info from pages 1-48...\n", '', ok])
      expect(util.pdf_page_count('/tmp/x', 'work')).to eq(48)
    end

    it 'renames the file even when its name has characters a shell would treat specially' do
      Dir.mktmpdir do |dir|
        name = 'a; touch hacked'
        File.write(File.join(dir, name), 'x')
        expect(util.rename_to_pdf(dir, name)).to be(true)
        expect(File.exist?(File.join(dir, "#{name}.pdf"))).to be(true)
        expect(File.exist?(File.join(dir, 'hacked'))).to be(false)
      end
    end
  end
end
