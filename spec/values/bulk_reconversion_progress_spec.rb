require 'rails_helper'

RSpec.describe BulkReconversionProgress do
  let(:requested_at) { Time.zone.parse('2026-11-12 10:00:00') }

  before do
    described_class.record(30, now: requested_at)
  end

  after do
    [described_class, ThumbnailRegenerationProgress].each do |klass|
      ApplicationSetting[klass::REQUESTED_AT_KEY] = ''
      ApplicationSetting[klass::REQUESTED_COUNT_KEY] = '0'
      ApplicationSetting[klass::FINISHED_AT_KEY] = ''
    end
  end

  it 'keeps its own record apart from the thumbnail regeneration' do
    expect(described_class.new(queue_length: 30, target_count: 30).requested_count).to eq(30)
    expect(ThumbnailRegenerationProgress.new(queue_length: 30).requested?).to be(false)
  end

  it 'does not count other messages in the queue as slides left to reconvert' do
    progress = described_class.new(now: requested_at + 10.minutes, queue_length: 25, target_count: 12)
    expect(progress.as_json).to include(done: 18, remaining: 12, finished: false)
  end

  it 'finishes when the queue is empty, even if some slides could not be converted' do
    progress = described_class.new(now: requested_at + 2.hours, queue_length: 0, target_count: 3)
    expect(progress.as_json).to include(done: 30, remaining: 0, finished: true)
  end

  it 'counts the slides still left from the slides table by default' do
    create(:slide)
    create(:slide, image_format: 'webp')
    expect(described_class.new(now: requested_at + 1.minute, queue_length: 10).remaining).to eq(1)
  end
end
