class ApplicationSetting
  @defaults = begin
                content = File.open(Rails.root.join('config', 'app.yml')).read
                hash = content.empty? ? {} : YAML.safe_load(ERB.new(content).result, [], [], true).to_hash
                hash = hash[Rails.env] || {}
                hash
              end

  @settings = begin
                arr = {}
                Setting.uncached do
                  Setting.all.reload.each do |res|
                    arr.store res.var.to_s, res.value
                  end
                end
                arr
              end

  @keys = [
    'site.display_login_link',
    'site.only_admin_can_upload',
    'site.signup_enabled',
    'site.name',
    'site.header_inverse',
    'custom_content.center_top',
    'custom_content.center_bottom',
    'custom_content.right_top',
    'custom_content.header_menus',
    'custom_content.css',
    'site.favicon',
    'site.footer',
    'site.theme'
  ]

  class << self
    def reload_settings
      @settings = load_settings
    end

    def load_settings
      arr = {}
      Setting.uncached do
        Setting.all.reload.each do |res|
          arr.store res.var.to_s, res.value
        end
      end
      arr
    end

    # get value
    def [](var_name)
      @settings = Rails.cache.fetch('settings', expires_in: 30.second) do
        load_settings
      end
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
      Rails.cache.clear
      reload_settings
    end

    def keys
      @settings.keys
    end

    def load_defaults(var_name)
      keys = var_name.to_s.split('.')
      @defaults.dig(*keys)
    end

    def unscoped
      Setting.unscoped
    end

    def save_default
      @keys.each do |key|
        next if Setting.exists?(var: key)
        s = Setting.new
        s.var = key
        s.value = self[key]
        s.save
      end
    end
  end
end
