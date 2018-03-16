xml.instruct! :xml, version: '1.0'
xml.rss('version' => '2.0', 'xmlns:dc' => 'http://purl.org/dc/elements/1.1/') do
  xml.channel do
    xml.title "#{strip_tags @user.display_name}'s slides | #{strip_tags ApplicationSetting['site.name']}"

    @slides.each do |slide|
      xml.item do
        xml.title strip_tags(slide.name)
        xml.description strip_tags(slide.description)
        xml.pubDate slide.created_at.to_s(:rfc822)
        xml.guid "#{root_url}slides/#{slide.id}"
        xml.link "#{root_url}slides/#{slide.id}"
        xml.author strip_tags(slide.user_display_name)
      end
    end
  end
end
