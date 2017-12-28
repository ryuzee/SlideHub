require 'rails_helper'

describe 'LogUtil' do
  describe 'escape_to_html' do
    it 'works' do
      str = "\e\[35mtest\e\[0m"
      expect(SlideHub::LogUtil.escape_to_html(str)).to eq '<span style="color:magenta; font-weight:bold">test</span>'
      str = "\e\[1mtest\e\[0m"
      expect(SlideHub::LogUtil.escape_to_html(str)).to eq '<span>test</span>'
      str = 'test'
      expect(SlideHub::LogUtil.escape_to_html(str)).to eq 'test'
    end
  end
end
