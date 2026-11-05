require 'rails_helper'

RSpec.describe SlideHub::Batch do
  let(:logger) { instance_double(Logger, info: nil, error: nil) }

  describe '.process' do
    it 'regenerates thumbnails for thumbnail messages' do
      procedure = instance_double(SlideHub::ThumbnailProcedure, run: true)
      expect(SlideHub::ThumbnailProcedure).to receive(:new).with(object_key: 'abc', logger: logger).and_return(procedure)
      expect(SlideHub::ConvertProcedure).not_to receive(:new)
      expect(described_class.process({ 'type' => 'thumbnail', 'id' => 1, 'object_key' => 'abc' }, logger)).to be(true)
    end

    it 'converts the slide for messages without a type' do
      procedure = instance_double(SlideHub::ConvertProcedure, run: true)
      expect(SlideHub::ConvertProcedure).to receive(:new).with(object_key: 'abc', logger: logger).and_return(procedure)
      expect(described_class.process({ 'id' => 1, 'object_key' => 'abc' }, logger)).to be(true)
    end
  end
end
