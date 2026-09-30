# Decision Records

ADRs are historical records, not current state. They say what was decided and why, as of their date. Never rewrite one to match a later change: append a dated "Superseded" note, or write a new ADR. Current conventions live in `../conventions/`.

Format: `000-template.md`. Files numbered sequentially: `001-short-title.md`.

## Decisions

- [001 — Database](001-database.md) — SQLite, one file per database under `storage/`
- [002 — Hosting and deployment](002-hosting.md) — no deploy; Docker Compose for development
- [003 — Authorization mechanism](003-authorization.md) — role callbacks + matrix spec, four roles
