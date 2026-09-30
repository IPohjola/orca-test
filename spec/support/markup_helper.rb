#
# Matches one tag by its attributes in any order. Rails helpers order
# attributes differently per helper, and data-action values contain ">".
module MarkupHelper
  ATTRS = '(?:[^>"]|"[^"]*")*'.freeze

  def tag_with(name, *attrs)
    /<#{name}\b#{attrs.map { |a| "(?=#{ATTRS}#{Regexp.escape(a)})" }.join}#{ATTRS}>/
  end
end

RSpec.configure do |config|
  config.include MarkupHelper, type: :request
end
