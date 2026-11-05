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
end
