module SettingsHelper
  def generate_form_field(setting, form)
    var = settings.var
    if %w[site.display_login_link site.only_admin_can_upload site.signup_enabled site.header_inverse].include?(var)
      return form.select :value, [%w[0 0], %w[1 1]], {}, { class: 'form-control' }
    end

    if %w[site.theme].include?(var)
      return form.select :value, [%w[default default], %w[dark dark], %w[white white]], {}, { class: 'form-control' }
    end

    if %w[site.name site.favicon site.footer].include?(var)
      return form.text_field :value, class: 'form-control'
    end
    form.text_area :value, class: 'form-control', size: '30x5'
  end
end
