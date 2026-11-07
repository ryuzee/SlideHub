module SettingsHelper
  # サイト設定画面のまとまり。ここに無い site.* の設定は「その他」に出す
  SETTING_GROUPS = {
    'general' => %w[site.name site.description site.footer site.favicon],
    'display' => %w[site.theme site.header_inverse site.thumbnail_aspect_ratio],
    'account' => %w[site.display_login_link site.signup_enabled site.only_admin_can_upload],
  }.freeze

  # オン/オフの設定（値は "0" / "1"）。スイッチで表示する
  BOOLEAN_SETTINGS = %w[site.display_login_link site.only_admin_can_upload site.signup_enabled site.header_inverse].freeze

  # テーマの選択肢と、色見本に使う主色（public/themes/*/bootstrap.css の primary）
  THEMES = { 'default' => '#e95420', 'dark' => '#375a7f', 'white' => '#222222', 'gray' => '#2f3c48' }.freeze

  # [[グループ名, [設定, ...]], ...] の順に並べる
  def grouped_settings(settings)
    by_var = settings.index_by(&:var)
    groups = SETTING_GROUPS.map { |name, vars| [name, vars.filter_map { |var| by_var[var] }] }
    others = settings.reject { |setting| SETTING_GROUPS.values.flatten.include?(setting.var) }
    (groups + [['other', others]]).reject { |_name, list| list.empty? }
  end

  def boolean_setting?(setting)
    BOOLEAN_SETTINGS.include?(setting.var)
  end

  def generate_form_field(setting, form)
    var = setting.var
    if boolean_setting?(setting)
      return form.check_box :value, { class: 'form-check-input', role: 'switch', id: setting_field_id(setting) }, '1', '0'
    end

    if var == 'site.theme'
      return form.select :value, THEMES.keys.map { |theme| [theme, theme] }, {}, { class: 'form-select', id: setting_field_id(setting) }
    end

    if var == 'site.thumbnail_aspect_ratio'
      return form.select :value, [%w[4:3 4:3], %w[16:9 16:9]], {}, { class: 'form-select', id: setting_field_id(setting) }
    end

    if %w[site.name site.favicon site.footer].include?(var)
      return form.text_field :value, class: 'form-control', id: setting_field_id(setting)
    end

    form.text_area :value, class: 'form-control', size: '30x5', id: setting_field_id(setting)
  end

  def setting_field_id(setting)
    "setting_#{setting.var.tr('.', '_')}"
  end
end
