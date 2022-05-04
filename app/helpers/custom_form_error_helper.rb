module CustomFormErrorHelper
  def errors(object, attribute)
    error_messages = object.try(:errors).try(:full_messages_for, attribute)

    if error_messages.is_a?(Array) && error_messages.count.positive?
      error_contents = create_error_div(error_messages)
    end
    error_contents || ''
  end

  def create_error_div(error_messages)
    result = <<~HTML
      <small class="help-block">#{error_messages.first}</small>
    HTML
    raw result
  end
end
