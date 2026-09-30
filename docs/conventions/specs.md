# Specs

Read before adding or changing any spec.

Owns: suite shape, the per-page bar, test data.

## Suite

RSpec. Layers, by default weight:

| Dir | Covers |
|---|---|
| `spec/requests` | Every controller action over real HTTP. Primary layer. |
| `spec/models` | Validations, scopes, calculations. |
| `spec/jobs`, `spec/mailers` | Enqueued work and rendered mail. |
| `spec/system` | Only flows that need JS to be observed. One per such flow, no more. |
| `spec/config`, `spec/db` | Invariants: settings resolve, indexes exist, encryption declared. |

Run: `bundle exec rspec`. CI runs the same command. A failing example is fixed or `pending`, never committed red.

## Bar for every page

`spec/requests/<controller>_spec.rb` exists for every controller. Minimum:

- `get` as each role that may reach it → `have_http_status(:ok)`.
- One example per conditional branch in the view.
- Form pages: valid params → redirect and record; invalid params → re-render and `:unprocessable_entity`.
- Filtered pages: one example proving the filter applies.
- Turbo Stream responses: assert the stream action and target.

Classification in `spec/requests/authorization_matrix_spec.rb` in the same change as the route.

## Conventions

- `sign_in(user)` posts real credentials. No stubbed `Current.user` in request specs.
- Markup: `tag_with("input", 'name="x"', 'value="y"')`. Attribute order varies per helper.
- Copy: `expect(response.body).to include(I18n.t("..."))`. Never a literal string.
- Time: `travel_to`. Never stub `Date.today` or `Time.now`.
- Mocks only at process boundaries (external APIs). None in request specs.
- `skip:` with a reason string naming the tracking item. Empty examples list under Pending.
- No `before(:all)` with database writes.

## Test data

`spec/support/factories.rb`: one `create_<model>(attrs = {})` per model, returning a saved record, defaults valid, unique fields via `SecureRandom`. A factory encodes every model invariant, so a spec cannot build a state the app forbids. Bypassing the write path in setup makes the spec fictional.

No fixtures. No seeds in specs.

## Safety

`rails_helper.rb` hard-sets `RAILS_ENV=test`, aborts unless the connected database is the test database, and truncates before the suite. Transactional examples otherwise.
