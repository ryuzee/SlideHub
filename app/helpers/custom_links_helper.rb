module CustomLinksHelper
  def custom_links
    require 'json'
    result = ''
    source = CustomSetting['custom_content.header_menus']
    begin
      return result if source.nil?
      json = JSON.parse(source, quirks_mode: true)
      json.each do |elm|
        if elm.is_a?(Hash) && elm.key?('label') && elm.key?('url')
          result += "<li>#{link_to elm['label'], elm['url']}</li>"
        end
      end
      return result
    rescue JSON::ParserError
      return ''
    end
  end
end
