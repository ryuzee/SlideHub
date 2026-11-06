require 'rails_helper'

RSpec.describe 'queue_length' do
  describe SlideHub::Cloud::Engine::Aws do
    it 'adds waiting and in-flight messages' do
      client = instance_double(Aws::SQS::Client)
      allow(described_class).to receive(:sqs).and_return(client)
      allow(client).to receive(:get_queue_attributes).and_return(
        double(attributes: { 'ApproximateNumberOfMessages' => '7', 'ApproximateNumberOfMessagesNotVisible' => '2' }),
      )
      expect(described_class.queue_length).to eq(9)
    end

    it 'returns nil when the queue cannot be read' do
      allow(described_class).to receive(:sqs).and_raise(StandardError)
      expect(described_class.queue_length).to be_nil
    end
  end

  describe SlideHub::Cloud::Engine::Azure do
    it 'returns the approximate message count' do
      queue_service = double(get_queue_metadata: [5, {}])
      allow(described_class).to receive(:create_qs).and_return(queue_service)
      expect(described_class.queue_length).to eq(5)
    end

    it 'returns nil when the queue cannot be read' do
      allow(described_class).to receive(:create_qs).and_raise(StandardError)
      expect(described_class.queue_length).to be_nil
    end
  end
end
