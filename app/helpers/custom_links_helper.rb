module CustomLinksHelper
  def custom_links
    require 'json'
    result = ''
    source = CustomSetting['custom_content.header_menus']
    begin
      json = JSON.parse(source)
      json.each do |j|
        if j.is_a?(Hash) && j.key?('label') && j.key?('url')
          result += "<li>#{link_to j['label'], j['url']}</li>"
        end
      end
      return result
    rescue JSON::ParserError
      return ''
    end
  end
end
