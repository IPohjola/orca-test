#
# Adds the required-field label class when the attribute has an unconditional
# presence validation. Set as config.action_view.default_form_builder.
class ApplicationFormBuilder < ActionView::Helpers::FormBuilder
  def label(method, text = nil, options = {}, &block)
    text, options = nil, text if text.is_a?(Hash)
    options = options.dup
    options[:class] = [ options[:class], "required-field" ].compact.join(" ") if required?(method)
    super(method, text, options, &block)
  end

  private

  def required?(method)
    klass = object&.class
    return false unless klass.respond_to?(:validators_on)

    klass.validators_on(method).any? do |validator|
      validator.kind == :presence && validator.options.slice(:if, :unless, :on).empty?
    end
  end
end
