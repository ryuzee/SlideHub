require 'rails_helper'

RSpec.describe AdminLayoutHelper, type: :helper do
  describe '#slide_status_badge' do
    it 'colors the badge by conversion status' do
      expect(helper.slide_status_badge(build(:slide, convert_status: :converted))).to include('text-bg-success')
      expect(helper.slide_status_badge(build(:slide, convert_status: :convert_error))).to include('text-bg-danger')
      expect(helper.slide_status_badge(build(:slide, convert_status: :unconverted))).to include('text-bg-secondary')
    end
  end

  describe '#advanced_search_used?' do
    it 'is true only when conditions other than the always visible ones are given' do
      allow(helper).to receive(:params).and_return(ActionController::Parameters.new(q: { name_cont: 'x', s: 'id asc' }))
      expect(helper.advanced_search_used?(%w[name_cont s])).to be(false)
      allow(helper).to receive(:params).and_return(ActionController::Parameters.new(q: { name_cont: 'x', convert_status_eq: '-1' }))
      expect(helper.advanced_search_used?(%w[name_cont s])).to be(true)
    end
  end
end
