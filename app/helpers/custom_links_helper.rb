module CustomLinksHelper
  def custom_links(controller)
    require 'json'
    result = ''
    source = CustomSetting['custom_content.header_menus']
    begin
      json = JSON.parse(source, quirks_mode: true)
      json.each do |elm|
        active_class = ''
        if elm['url'].start_with?("#{root_url}pages/", '/pages/') && controller.controller_name == 'pages'
          active_class = ' class="active"'
        end
        result += "<li#{active_class}>#{link_to elm['label'], elm['url']}</li>"
      end
    rescue StandardError
      result = ''
    end
    result
  end
end
