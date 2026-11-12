require 'rails_helper'

RSpec.describe BulkReconversionService do
  it 'asks to reconvert only the converted slides whose images are not WebP yet' do
    old = create(:slide)
    create(:slide, image_format: 'webp')
    create(:slide, convert_status: Slide.convert_statuses[:unconverted])
    create(:slide, convert_status: Slide.convert_statuses[:convert_error])
    sent = []
    allow(CloudConfig.provider).to receive(:send_message) { |message| sent << JSON.parse(message) }

    expect(described_class.targets).to eq([old])
    expect(described_class.new.request_all).to eq(1)
    expect(sent.size).to eq(1)
    expect(sent.first).to include('id' => old.id, 'object_key' => old.object_key)
    # 結果は新しいキーに置き、終わってから切り替える（それまでは今の画像が表示される）
    expect(sent.first['new_object_key']).to match(/\A\h{32}\z/)
  end
end
