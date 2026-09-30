require "spec_helper"

# Hard-set, not ||=: a container or shell presetting RAILS_ENV must not boot
# the suite against the development database.
ENV["RAILS_ENV"] = "test"
require_relative "../config/environment"

abort("Refusing to run: RAILS_ENV is #{Rails.env}, not test.") unless Rails.env.test?

db = ActiveRecord::Base.connection_db_config.database
abort("Refusing to run: database #{db} is not a test database.") unless File.basename(db.to_s, ".*").end_with?("_test")

require "rspec/rails"

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

Rails.root.glob("spec/support/**/*.rb").sort.each { |f| require f }

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.filter_rails_from_backtrace!
  config.include ActiveSupport::Testing::TimeHelpers
  config.include ActiveJob::TestHelper

  # Rows committed outside a rolled-back transaction by an earlier run.
  config.before(:suite) do
    connection = ActiveRecord::Base.connection
    tables = connection.tables - %w[schema_migrations ar_internal_metadata]
    connection.truncate_tables(*tables) if tables.any?
  end
end
