require 'rails_helper'

RSpec.describe Dashboard do
  describe '#monthly_upload_counts' do
    it 'counts slides per month for the last months, including empty months' do
      now = Time.zone.parse('2026-11-15 12:00')
      create(:slide, created_at: Time.zone.parse('2026-11-01 00:30'))
      create(:slide, created_at: Time.zone.parse('2026-11-10'))
      create(:slide, created_at: Time.zone.parse('2026-09-30 23:30'))
      create(:slide, created_at: Time.zone.parse('2026-07-31'))

      counts = described_class.new.monthly_upload_counts(months: 3, now: now)
      expect(counts).to eq([[Date.new(2026, 9, 1), 1], [Date.new(2026, 10, 1), 0], [Date.new(2026, 11, 1), 2]])
    end
  end
end
