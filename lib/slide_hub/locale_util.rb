module SlideHub
  class LocaleUtil
    def self.locale(request)
      locale = locale_from_accept_language(request)
      (I18n.available_locales.include?(locale.to_sym) ? locale.to_sym : I18n.default_locale)
    end

    def self.locale_from_accept_language(request)
      if request.env.key?('HTTP_ACCEPT_LANGUAGE')
        request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
      else
        I18n.default_locale
      end
    end
  end
end
