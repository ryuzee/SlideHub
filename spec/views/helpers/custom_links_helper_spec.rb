require 'rails_helper'

RSpec.describe CustomLinksHelper, type: :helper do
  describe 'custom_links' do
    class DummyController
      attr_reader :controller_name

      def initialize
        @controller_name = 'pages'
      end
    end
    controller = DummyController.new

    it "returns '' when option is nil" do
      begin
        ApplicationSetting['custom_content.header_menus'] = nil
        expect(helper.custom_links(controller)).to eq ''
      ensure
        ApplicationSetting['custom_content.header_menus'] = '[]'
      end
    end

    it "returns '' when option is empty" do
      begin
        ApplicationSetting['custom_content.header_menus'] = ''
        expect(helper.custom_links(controller)).to eq ''
      ensure
        ApplicationSetting['custom_content.header_menus'] = '[]'
      end
    end

    it "returns '' when option is not a valid json" do
      begin
        ApplicationSetting['custom_content.header_menus'] = '["a", "b", "c"]'
        expect(helper.custom_links(controller)).to eq ''
      ensure
        ApplicationSetting['custom_content.header_menus'] = '[]'
      end
    end

    it "returns '' when json does not include the specific keys" do
      begin
        ApplicationSetting['custom_content.header_menus'] = '[
          {"label": "test1", "_url": "error"},
          {"_label": "test2", "url": "error"}
        ]'
        expect(helper.custom_links(controller)).to eq ''
      ensure
        ApplicationSetting['custom_content.header_menus'] = '[]'
      end
    end

    it 'returns valid html' do
      begin
        ApplicationSetting['custom_content.header_menus'] = '[
          {"label": "test1", "url": "http://test1.example.com/"},
          {"label": "test2", "url": "https://test2.example.com/"}
        ]'
        expect(helper.custom_links(controller)).to include('<li><a href="https://test2.example.com/">test2</a></li>')
      ensure
        ApplicationSetting['custom_content.header_menus'] = '[]'
      end
    end

    it 'includes "active" attribute in css class' do
      begin
        ApplicationSetting['custom_content.header_menus'] = '[
          {"label": "test", "url": "/pages/test"}
        ]'
        expect(helper.custom_links(controller)).to include('<li class="active"><a href="/pages/test">test</a></li>')
      ensure
        ApplicationSetting['custom_content.header_menus'] = '[]'
      end
    end
  end
end
