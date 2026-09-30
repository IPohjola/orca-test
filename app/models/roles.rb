# Role sets. Controllers, nav items and specs use these constants; never inline role predicates.
# Rules: docs/conventions/backend.md → Authorization. Decision: docs/decisions/003-authorization.md.
module Roles
  ALL        = %i[admin instructor customer customer_custodian].freeze
  ADMIN      = %i[admin].freeze
  STAFF      = %i[admin instructor].freeze
  CUSTOMERS  = %i[customer].freeze
  CUSTODIANS = %i[customer_custodian].freeze
end
