module DeviseHelper
  # エラーメッセージを、閉じるボタン付きのアラートで並べる。メッセージはエスケープする
  def bootstrap_devise_error_messages!
    return '' if resource.errors.empty?

    alerts = resource.errors.full_messages.map do |error_message|
      close_button = content_tag(:button, '', type: 'button', class: 'btn-close', data: { bs_dismiss: 'alert' }, aria: { label: 'close' })
      content_tag(:div, safe_join([close_button, error_message]), class: 'alert alert-danger alert-dismissible', role: 'alert')
    end
    safe_join(alerts)
  end
end
