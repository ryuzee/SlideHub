require 'rails_helper'

RSpec.describe SlideHub::SessionCleanup do
  let(:logger) { instance_double(Logger, info: nil, error: nil) }
  let(:session_class) { ActiveRecord::SessionStore::Session }

  def create_session(id, updated_at)
    session_class.create!(session_id: id, data: session_class.serialize({}), updated_at: updated_at)
  end

  it 'deletes sessions not used for longer than the remember period, and keeps the others' do
    create_session('old', Devise.remember_for.ago - 1.day)
    create_session('recent', 1.day.ago)
    expect(described_class.run(logger)).to eq(1)
    expect(session_class.pluck(:session_id)).to eq(['recent'])
  end

  it 'logs and carries on when deleting fails' do
    allow(session_class).to receive(:where).and_raise(StandardError, 'boom')
    expect(logger).to receive(:error).with(/boom/)
    expect(described_class.run(logger)).to eq(0)
  end
end
