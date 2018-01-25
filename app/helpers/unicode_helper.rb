module UnicodeHelper
  def clear_invisible_string(str)
    str.gsub!(/\u{2028}/, '')
    str.gsub!(/\u{000c}/, '')
  end
end
