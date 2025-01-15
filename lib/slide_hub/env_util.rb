module SlideHub
  class EnvUtil
    def self.fetch(key, default = nil)
      prefixes = %w[SLIDEHUB_ OSS_]
      prefixes.each do |prefix|
        value = ENV.fetch("#{prefix}#{key}", nil)
        return value unless value.nil?
      end
      default
    end
  end
end
