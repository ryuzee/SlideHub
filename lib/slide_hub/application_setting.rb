class ApplicationSetting
  @settings = begin
                arr = {}
                Setting.all.each do |res|
                  arr.store res.var.to_s, res.value
                end
                arr
              end
  @defaults = begin
                content = open(Rails.root.join('config/app.yml')).read
                hash = content.empty? ? {} : YAML.load(ERB.new(content).result).to_hash
                hash = hash[Rails.env] || {}
                hash
              end

  class << self

    def load
      Setting.all.each do |res|
        @settings.store res.var.to_s, res.value
      end
    end

    # get value
    def [](var_name)
      var_name = var_name.to_s
      @settings.fetch(var_name, load_defaults(var_name))
    end

    # set value
    def []=(var_name, value)
      var_name = var_name.to_s
      setting = Setting.find_or_create_by(var: var_name) do |s|
        s.var = var_name
      end
      setting.value = value
      setting.save
      load
    end

    def keys
      @settings.keys
    end

    def load_defaults(var_name)
      keys = var_name.to_s.split('.')
      @defaults.dig(*keys)
    end
  end
end
