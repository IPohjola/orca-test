#
# Every helper returns a saved record with valid defaults. Unique fields use
# SecureRandom so several records fit in one example. A factory encodes every
# model invariant: pass related records to reuse them, or any column to override.
require "securerandom"

module Factories
  def create_user(attrs = {})
    uid = SecureRandom.hex(4)
    User.create!({
      email_address: "user_#{uid}@example.com",
      password: "password",
      role: :customer
    }.merge(attrs))
  end

  def create_admin(attrs = {})
    create_user({ role: :admin }.merge(attrs))
  end

  # Pattern for a record with required parents:
  #
  # def create_diary_entry(attrs = {})
  #   attrs = attrs.dup
  #   author = attrs.delete(:author) || create_user
  #   DiaryEntry.create!({ author: author, body: "Today" }.merge(attrs))
  # end
end

RSpec.configure do |config|
  config.include Factories
end
