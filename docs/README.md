# Docs

Instructions for future work. Each fact has one owner file; other files link to it. Inventories are not written down: the tree is the inventory, these files are the rules.

## Read on demand

| Doc | Read when |
|---|---|
| [`conventions/backend.md`](conventions/backend.md) | Touching a model, controller, job, mailer, migration, config file or locale |
| [`conventions/specs.md`](conventions/specs.md) | Writing or changing any spec |
| [`conventions/frontend/page-layout.md`](conventions/frontend/page-layout.md) | Building a page, touching a layout or shared CSS |
| [`conventions/frontend/forms.md`](conventions/frontend/forms.md) | Building or changing a form |
| [`conventions/frontend/javascript.md`](conventions/frontend/javascript.md) | Adding or changing JS behaviour |
| [`conventions/frontend/tokens.md`](conventions/frontend/tokens.md) | Adding a token or picking a unit |
| [`conventions/frontend/navigation.md`](conventions/frontend/navigation.md) | Touching the nav or a back link |
| [`decisions/DECISIONS.md`](decisions/DECISIONS.md) | Before proposing a dependency, pattern or infra change |
| [`todo/`](todo/) | Picking backlog work |

## Decision rules

- **Status sweep at controller level.** Fixing one missing `status: :unprocessable_entity` fixes every form-failure render in that controller.
- **Chosen libraries are not re-litigated per page.** `DECISIONS.md` lists them.
- **Reference implementations over invention.** Before building a page, copy the closest row below.

## Reference implementations

One row per page shape. Add a row only for the first page of a new shape. Not a progress log.

| Shape | Files | Copy for |
|---|---|---|
| _(fill when the first page exists)_ | | |
