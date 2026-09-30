# Backend conventions

Read when touching a model, controller, job, mailer, migration, config file or locale.

Owns: schema, models, controllers, authorization, jobs, configuration, i18n.
Not here: specs → [specs.md](specs.md). Views and JS → [frontend/](frontend/).

## Schema

- Every `*_id` column: `t.references :x, null: false, foreign_key: true`. Nullable only with the reason in the migration.
- `on_delete:` explicit on every foreign key. Default `:restrict`; `:cascade` only for owned children (line items, attachments).
- Money: `decimal, precision: 12, scale: 2`. Never float.
- Time: `datetime` for instants, `date` for days, `time` for clock times. Never strings.
- Enumerations: `integer` column, `null: false, default: 0`, Rails `enum` in the model. Display text in locale files.
- Booleans: `null: false, default: false`. No tri-state booleans.
- Personal data: `encrypts :attribute` in the model. Deterministic only if queried by equality.
- Timestamps on every table. Unique indexes for every uniqueness validation.
- One concept, one table. Parallel entity families use STI or a `type` column, never copied tables.
- Migrations use `change`. Schema-only; data backfills are jobs or rake tasks run by hand.
- Squash migrations once deployed everywhere: `db/schema.rb` is authoritative.

## Models

- Inherit `ApplicationRecord`.
- Class-level queries are `scope`s. A `def self.find_*` that returns a relation is a scope.
- Validations use the `validates :attr, presence: true` form.
- No `default_scope`. Soft delete is an explicit scope (`kept`, `discarded`).
- Callbacks only for bookkeeping the record owns. Side effects on other systems go to jobs.
- Domain calculations that outgrow a model method go to `app/models/<domain>/` as plain Ruby objects with specs. `lib/` is for code with no domain knowledge.
- Value objects: `Data.define`.
- `Current` (`ActiveSupport::CurrentAttributes`) carries the request user into models. No `attr_accessor :current_user`.
- Setters do not mutate arguments. Parse input in the controller or a form object, not in a writer.

## Controllers

- Resourceful. A custom action is a resource in disguise; add a nested resource instead.
- Thin: load, authorize, call one model or service method, respond. Business logic never lives here.
- `params.expect(model: [...])`.
- Form failure renders `status: :unprocessable_entity`.
- `respond_to` with `turbo_stream` and `html` where a Turbo Stream response exists. Turbo Stream responses that change state also re-render the flash region.
- Concerns in `app/controllers/concerns/`. Services in `app/services/`, named after what they do (`InvoiceBuilder`), never `*Helper`.
- Reports and exports: build rows in a plain object under `app/models/<domain>/`, render in the controller or a job. The object is unit-tested; the controller gets a request spec.
- Never read `request.referrer` to decide behaviour.
- No `rescue_from StandardError`. Rescue specific errors.

## Authorization

One mechanism. Role sets are frozen constants in one file:

```ruby
# app/models/roles.rb
module Roles
  ALL        = %i[admin manager staff].freeze
  ADMIN      = %i[admin].freeze
  MANAGEMENT = %i[admin manager].freeze
end
```

`ApplicationController`:

```ruby
before_action :require_role_declared

def require_role(*roles)
  return if Current.user&.role_in?(roles)
  redirect_to root_path, alert: t("authorization.denied")
end
```

Rules:

- Deny by default: a controller with no role declaration is denied. Declare with `before_action -> { require_role(*Roles::MANAGEMENT) }` and `skip_before_action :require_role_declared`. Prefer bare or `except:` so a new action lands guarded.
- Record visibility: one `visible_<models>` private method per controller returning a relation. Member actions `find` through it. A record outside scope is a 404, indistinguishable from a missing one.
- Field authorization: frozen attribute lists per role, assembled in `permitted_<model>_attributes`. Never one `permit` list for all roles.
- Views and navigation use the same `Roles` constants as the controller they link to. Nav item: `roles: Roles::MANAGEMENT`; helper `permitted?(roles)`. No inline role predicates in views.
- `spec/requests/authorization_matrix_spec.rb` classifies every routed action. Fails until routes and rows agree.
- `config.action_controller.raise_on_missing_callback_actions = true` in test.
- Adopt a policy library only through an ADR that names what the constants could not express.

## Jobs and mail

- Solid Queue in every environment.
- Mail: `deliver_later`. `deliver_now` is not permitted in a request.
- Anything slower than a query — PDF, CSV, import, external API — runs in a job. The request enqueues and responds.
- Recurring work: `config/recurring.yml`. No external cron.
- Mailers take ids or records and render. Recipient selection and data queries live in the caller.
- Non-production mail: `config.action_mailer.interceptors` or a settings-driven recipient override. Never `Rails.env` branches inside a mailer.

## Configuration

Four places, one rule each:

- `config/settings.yml` — application values that differ per environment: addresses, hostnames, feature limits. Read via `config_for(:settings)` as `Rails.configuration.settings.<key>`. `shared` supplies defaults. Keys flat. Values literal; an `ENV` read appears in this file only when infra alone knows the value.
- Environment variables — only what the repo cannot know: secrets and runtime facts (`DATABASE_URL`, `RAILS_ENV`). Required ones are checked at boot in `config/application.rb`.
- `config/environments/*.rb` — framework configuration. The only place framework values differ per environment.
- `config/initializers/*.rb` — values identical in every environment. An initializer guarding by environment uses a whitelist (`Rails.env.production?`), never a blacklist.

No Ruby constants for configuration. `spec/config/settings_spec.rb` asserts every key resolves in every environment.

Secrets: `config/credentials/<env>.yml.enc`. Master keys in the team password manager and the deploy secret store. Never in a file in the image.

## i18n

- `config.i18n.default_locale` and `config.time_zone` set in `application.rb`.
- Every user-visible string in `config/locales/<lang>.yml`: flash messages, labels, validation messages, model and attribute names, nav labels.
- Views: `t(".key")` lazy lookup. Controllers: `t("controller.action.key")`.
- Specs assert `I18n.t(...)`, never literal copy.
- No `human_attribute_name` overrides. Attribute names go in `activerecord.attributes`.

## Security defaults

- CSP enforced from the first deploy, nonce on the importmap tag. Report-only is a staging step, not a state.
- `config.hosts` set per environment. `force_ssl` in production and staging; exclude the health-check path.
- `filter_parameter_logging` covers every personal-data attribute.
- Error tracking service configured before the first deploy. Email is not error tracking.
