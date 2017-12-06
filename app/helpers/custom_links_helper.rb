module CustomLinksHelper
  def custom_links
    require 'json'
    result = ''
    source = CustomSetting['custom_content.header_menus']
    begin
      json = JSON.parse(source, quirks_mode: true)
      json.each do |elm|
        result += "<li>#{link_to elm['label'], elm['url']}</li>"
      end
    ensure
      return result
    end
  end
end
