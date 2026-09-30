# CLAUDE.md

Rails 8 monolith. Ruby version in `.ruby-version`. Stack: PostgreSQL, Propshaft, importmap, Hotwire, Solid Queue, RSpec.

## Philosophy

Do things the documented, intended way. When applying a library, framework or pattern, use its canonical form as its own docs show it. No project-specific magic layers: no global DOM walkers, autoapply hooks, monkey-patches, naming-convention auto-wiring, hidden side-effect imports. A shortcut that avoids touching many call sites becomes debt the moment it lands.

If the canonical pattern means touching many files, say so and ask. Do not paper over it.

## Guidelines

- Answer the question, then stop. No unsolicited opinions, recommendations or next steps.
- Do not implement unless asked. When offering options, ask first.
- Prune filler. A word whose deletion loses nothing goes: "as needed", "explicitly", "it's worth noting", hedges.
- Comments only where the name does not carry the meaning. Short.
- Use `puts` for debug output.
- Direct edits only. No patches.
- Never stage, commit or push unless asked. Git is read-only by default.
- Prefer Rails built-ins over custom solutions: `disable_with` over inline JS, callbacks over manual bookkeeping, `touch: true` over custom timestamps, `enum` over string constants, `deliver_later` over `deliver_now`.

## Commands

```bash
bin/rails console
bin/rails db:migrate            # user runs migrations; agent writes them
bundle exec rspec
bundle exec rspec spec/path_spec.rb:42
bin/rubocop
bin/brakeman
bin/jobs                        # Solid Queue worker
```

## Conventions

Router: `docs/README.md`. Read the doc for the area before touching it.

- Migrations: `change`, never `up`/`down`. Check `db/schema.rb` for column names before writing params.
- Every route has a request spec. Bar: `docs/conventions/specs.md`.
- Every controller action is classified in `spec/requests/authorization_matrix_spec.rb`.
- User-visible strings live in `config/locales/`. Views use `t(".key")`. Specs assert `I18n.t`, never literals.
- No inline `<script>`, no `on*` attributes, no `style` attributes in views.

## Documentation reconciliation

Docs in `docs/` are instructions for future work, not a record of past work. Each fact has one owner file; other files link to it.

Before finishing a task that touched a documented area, compare the change against the governing doc. Resolve every conflict explicitly:

- Doc right, code wrong → fix the code.
- Doc stale → update it, and say so.
- Deliberate change of direction → say so and confirm before editing the doc.

Never rewrite a doc to match your own change silently.

Writing rules for docs:

- Verify before asserting. A claim naming a file, count or attribute is checked against the tree first.
- Don't write what a grep can produce. Point at the source.
- Falsifiable statements only.
- State what is true and what to do. No history, no progress narration.

## Decision records

Create an ADR in `docs/decisions/` from `000-template.md` when a conversation decides one of:

- Adding, replacing or removing a dependency or service
- Non-trivial data-model change
- A new architectural pattern
- Infrastructure or deployment change
- A choice between meaningfully different technical approaches

Not ADRs: UI choices, bug fixes, routine feature work, non-architectural refactoring.

Number sequentially, update `docs/decisions/DECISIONS.md`, mention it in one line. Do not ask whether to create it.
