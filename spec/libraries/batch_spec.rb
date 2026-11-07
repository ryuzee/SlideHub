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
      expect(SlideHub::ConvertProcedure).to receive(:new).
        with(object_key: 'abc', new_object_key: nil, previous_object_key: nil, logger: logger).and_return(procedure)
      expect(described_class.process({ 'id' => 1, 'object_key' => 'abc' }, logger)).to be(true)
    end

    it 'passes the new and previous keys to the conversion' do
      procedure = instance_double(SlideHub::ConvertProcedure, run: true)
      expect(SlideHub::ConvertProcedure).to receive(:new).
        with(object_key: 'abc', new_object_key: 'def', previous_object_key: 'xyz', logger: logger).and_return(procedure)
      described_class.process({ 'id' => 1, 'object_key' => 'abc', 'new_object_key' => 'def', 'previous_object_key' => 'xyz' }, logger)
    end
  end

  describe '.execute' do
    let(:provider) { CloudConfig.provider }

    # キューから受け取ったことにするメッセージ
    def queue_with(*bodies)
      response = SlideHub::Cloud::Queue::Response.new
      bodies.each_with_index { |body, i| response.add_message(i, body.to_json, "handle-#{i}") }
      response
    end

    before do
      allow(SlideHub::BatchLogger).to receive_messages(info: nil, error: nil)
    end

    it 'deletes old sessions on every run, even when the queue is empty' do
      allow(provider).to receive(:receive_message).and_return(SlideHub::Cloud::Queue::Response.new)
      expect(SlideHub::SessionCleanup).to receive(:run).with(SlideHub::BatchLogger)
      described_class.execute
    end

    it 'does nothing when the queue is empty' do
      allow(provider).to receive(:receive_message).and_return(SlideHub::Cloud::Queue::Response.new)
      expect(described_class).not_to receive(:process)
      expect(provider).not_to receive(:delete_message)
      expect(described_class.execute).to be(true)
    end

    it 'deletes a message after converting the slide' do
      allow(provider).to receive(:receive_message).and_return(queue_with({ 'id' => 1, 'object_key' => 'abc' }))
      allow(described_class).to receive(:process).and_return(true)
      expect(provider).to receive(:delete_message).with(having_attributes(handle: 'handle-0'))
      described_class.execute
    end

    it 'keeps a message whose conversion failed, so that it is tried again' do
      allow(provider).to receive(:receive_message).and_return(queue_with({ 'id' => 1, 'object_key' => 'abc' }))
      allow(described_class).to receive(:process).and_return(false)
      expect(provider).not_to receive(:delete_message)
      expect(SlideHub::BatchLogger).to receive(:error).with(/Processing failed/)
      described_class.execute
    end

    it 'deletes a thumbnail message even when it failed, because trying again does not help' do
      allow(provider).to receive(:receive_message).and_return(queue_with({ 'type' => 'thumbnail', 'id' => 1, 'object_key' => 'abc' }))
      allow(described_class).to receive(:process).and_return(false)
      expect(provider).to receive(:delete_message)
      described_class.execute
    end

    it 'handles each message on its own' do
      bodies = [{ 'id' => 1, 'object_key' => 'ok' }, { 'id' => 2, 'object_key' => 'ng' }]
      allow(provider).to receive(:receive_message).and_return(queue_with(*bodies))
      allow(described_class).to receive(:process) { |obj, _logger| obj['object_key'] == 'ok' }
      expect(provider).to receive(:delete_message).once.with(having_attributes(handle: 'handle-0'))
      described_class.execute
    end
  end
end
