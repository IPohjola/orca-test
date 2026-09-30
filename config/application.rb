require_relative "boot"

# Explicit railties instead of rails/all. Uncomment what a feature needs.
require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
# require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module Harbor
  class Application < Rails::Application
    config.load_defaults 8.1

    config.autoload_lib(ignore: %w[assets tasks])

    config.time_zone = "Helsinki"
    config.i18n.default_locale = :en
    config.i18n.available_locales = [ :en ]

    config.action_view.default_form_builder = "ApplicationFormBuilder"

    config.generators.system_tests = nil

    # Per-environment application values. Rules: docs/conventions/backend.md → Configuration.
    config.settings = config_for(:settings)

    # Checked at boot so a missing variable fails here, not on the first request.
    # :all — every non-test boot. :mail — only when delivering over SMTP.
    REQUIRED_ENV = {
      "SMTP_PASSWORD" => :mail
    }.freeze

    config.after_initialize do
      next if Rails.env.test? || ENV["SECRET_KEY_BASE_DUMMY"].present?

      missing = REQUIRED_ENV.filter_map do |name, scope|
        next if scope == :mail && ActionMailer::Base.delivery_method != :smtp

        name if ENV[name].blank?
      end

      raise "Missing required environment variables: #{missing.join(', ')}" if missing.any?
    end
  end
end
