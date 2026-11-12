require 'rails_helper'

RSpec.describe ThumbnailRegenerationProgress do
  let(:requested_at) { Time.zone.parse('2026-11-06 10:00:00') }

  before do
    described_class.record(100, now: requested_at)
  end

  after do
    ApplicationSetting[described_class::REQUESTED_AT_KEY] = ''
    ApplicationSetting[described_class::REQUESTED_COUNT_KEY] = '0'
    ApplicationSetting[described_class::FINISHED_AT_KEY] = ''
  end

  it 'estimates the remaining time from the observed rate' do
    progress = described_class.new(now: requested_at + 10.minutes, queue_length: 60)
    expect(progress.requested?).to be(true)
    expect(progress.done).to eq(40)
    expect(progress.remaining).to eq(60)
    # 40 件を 600 秒で処理したので、残り 60 件は 900 秒
    expect(progress.estimated_seconds).to eq(900)
    expect(progress.finished?).to be(false)
  end

  it 'uses the default batch rate before anything is processed' do
    progress = described_class.new(now: requested_at + 5.seconds, queue_length: 100)
    expect(progress.done).to eq(0)
    expect(progress.estimated_seconds).to eq((100 / described_class::DEFAULT_RATE).ceil)
  end

  it 'uses the default batch rate while only a few have been processed, even long after the request' do
    progress = described_class.new(now: requested_at + 6.days, queue_length: 98)
    expect(progress.done).to eq(2)
    expect(progress.estimated_seconds).to eq((98 / described_class::DEFAULT_RATE).ceil)
  end

  it 'does not count more than requested when other messages are in the queue' do
    progress = described_class.new(now: requested_at + 1.minute, queue_length: 130)
    expect(progress.remaining).to eq(100)
    expect(progress.done).to eq(0)
  end

  it 'is finished when the queue is empty' do
    progress = described_class.new(now: requested_at + 1.hour, queue_length: 0)
    expect(progress.finished?).to be(true)
    expect(progress.estimated_seconds).to eq(0)
    expect(progress.as_json).to include(done: 100, remaining: 0, finished: true)
  end

  it 'reports nothing when the queue length is unavailable' do
    progress = described_class.new(now: requested_at + 1.minute, queue_length: nil)
    expect(progress.as_json).to include(requested: true, remaining: nil, done: nil, estimated_seconds: nil, finished: false)
  end

  it 'does not finish right after the request, while the queue length still lags behind' do
    progress = described_class.new(now: requested_at + 5.seconds, queue_length: 0)
    progress.remember_finish
    expect(progress.as_json).to include(done: 0, remaining: 100, finished: false)
    expect(described_class.new(now: requested_at + 3.minutes, queue_length: 100).finished?).to be(false)
  end

  it 'stays finished once finished, even when other work fills the queue again' do
    described_class.new(now: requested_at + 1.hour, queue_length: 0).remember_finish
    progress = described_class.new(now: requested_at + 2.hours, queue_length: 40)
    expect(progress.as_json).to include(done: 100, remaining: 0, finished: true, estimated_seconds: 0)
  end

  it 'does not remember a finish before the queue is empty' do
    described_class.new(now: requested_at + 1.minute, queue_length: 10).remember_finish
    expect(described_class.new(now: requested_at + 2.minutes, queue_length: 10).finished?).to be(false)
  end

  it 'starts over when requested again' do
    described_class.new(now: requested_at + 1.hour, queue_length: 0).remember_finish
    described_class.record(50, now: requested_at + 2.hours)
    expect(described_class.new(now: requested_at + 2.hours, queue_length: 50).as_json).to include(done: 0, finished: false)
  end

  it 'is not requested before the first run' do
    ApplicationSetting[described_class::REQUESTED_AT_KEY] = ''
    expect(described_class.new(queue_length: 0).requested?).to be(false)
  end
end
