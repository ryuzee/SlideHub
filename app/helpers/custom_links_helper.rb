module CustomLinksHelper
  def custom_links
    require 'json'
    result = ''
    source = CustomSetting['custom_content.header_menus']
    begin
      return result if source.nil?
      json = JSON.parse(source, quirks_mode: true)
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
