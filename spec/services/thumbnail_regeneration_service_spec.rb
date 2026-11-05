require 'rails_helper'

RSpec.describe ThumbnailRegenerationService do
  it 'sends a thumbnail message for each converted slide only' do
    converted = create(:slide)
    create(:slide, convert_status: Slide.convert_statuses[:unconverted])
    sent = []
    allow(CloudConfig.provider).to receive(:send_message) { |message| sent << JSON.parse(message) }

    expect(described_class.new.request_all).to eq(1)
    expect(sent).to eq([{ 'type' => 'thumbnail', 'id' => converted.id, 'object_key' => converted.object_key }])
  end
end
