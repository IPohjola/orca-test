require "rails_helper"

RSpec.describe "config/settings.yml" do
  ENVIRONMENTS = %w[development test staging production].freeze
  KEYS = %i[mailer_host mail_from support_email error_report_email].freeze
  HOST_KEYS = %i[mailer_host].freeze

  def settings_for(env)
    Rails.application.config_for(:settings, env: env)
  end

  ENVIRONMENTS.each do |env|
    it "resolves every key in #{env}" do
      settings = settings_for(env)
      missing = KEYS.reject { |key| settings[key].present? }
      expect(missing).to eq([])
    end
  end

  it "keeps hosts as bare hostnames" do
    ENVIRONMENTS.each do |env|
      HOST_KEYS.each do |key|
        value = settings_for(env)[key]
        expect(value).not_to match(%r{\Ahttps?://|/\z}), "#{env}.#{key} = #{value}"
      end
    end
  end

  it "differs between staging and production" do
    expect(settings_for("staging")).not_to eq(settings_for("production"))
  end

  it "does not deliver mail from the test environment" do
    expect(ActionMailer::Base.delivery_method).to eq(:test)
  end
end
