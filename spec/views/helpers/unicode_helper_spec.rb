require 'rails_helper'

RSpec.describe UnicodeHelper, type: :helper do
  describe 'clear_invisible_string' do
    it "removes control code" do
      controls = ["a\u{2028}b", "a\u{000c}b"]
      controls.each do |c|
        c = helper.clear_invisible_string(c)
        expect(c).to eq 'ab'
      end
    end
  end
end
