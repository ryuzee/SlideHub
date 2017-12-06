require 'spec_helper'
require 'rails_helper'

RSpec.describe CustomLinksHelper, type: :helper do
  describe 'custom_links' do
    it "returns '' when option is nil" do
      begin
        CustomSetting['custom_content.header_menus'] = nil
        expect(helper.custom_links).to eq ''
      ensure
        CustomSetting['custom_content.header_menus'] = '[]'
      end
    end

    it "returns '' when option is empty" do
      begin
        CustomSetting['custom_content.header_menus'] = ''
        expect(helper.custom_links).to eq ''
      ensure
        CustomSetting['custom_content.header_menus'] = '[]'
      end
    end

    it "returns '' when option is not a valid json" do
      begin
        CustomSetting['custom_content.header_menus'] = '["a", "b", "c"]'
        expect(helper.custom_links).to eq ''
      ensure
        CustomSetting['custom_content.header_menus'] = '[]'
      end
    end

    it "returns '' when json does not include the specific keys" do
      begin
        CustomSetting['custom_content.header_menus'] = '[
          {"label": "test1", "_url": "error"},
          {"_label": "test2", "url": "error"}
        ]'
        expect(helper.custom_links).to eq ''
      ensure
        CustomSetting['custom_content.header_menus'] = '[]'
      end
    end

    it 'returns valid html' do
      begin
        CustomSetting['custom_content.header_menus'] = '[
          {"label": "test1", "url": "http://test1.example.com/"},
          {"label": "test2", "url": "https://test2.example.com/"}
        ]'
        expect(helper.custom_links).to include('<li><a href="https://test2.example.com/">test2</a></li>')
      ensure
        CustomSetting['custom_content.header_menus'] = '[]'
      end
    end
  end
end
