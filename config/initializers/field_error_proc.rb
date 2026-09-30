#
# Wraps an invalid control with aria-invalid, aria-describedby and its message
# in flow. Labels, checkboxes and radios are left alone.
SKIPPED_FIELD_ERROR_TAGS = [
  ActionView::Helpers::Tags::Label,
  ActionView::Helpers::Tags::CheckBox,
  ActionView::Helpers::Tags::RadioButton
].freeze

ActionView::Base.field_error_proc = lambda do |html_tag, instance|
  next html_tag if SKIPPED_FIELD_ERROR_TAGS.any? { |klass| instance.is_a?(klass) }

  message = ERB::Util.html_escape(instance.error_message.to_sentence)
  error_id = "field-error-#{SecureRandom.hex(4)}"

  decorated_tag = html_tag.sub(
    /<(input|select|textarea)\b/,
    %(<\\1 aria-invalid="true" aria-describedby="#{error_id}")
  )

  %(<span class="field-error-wrapper">#{decorated_tag}<span id="#{error_id}" class="field-error-message">#{message}</span></span>).html_safe
end
