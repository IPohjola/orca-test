# 002 — Hosting and deployment

**Date:** 2026-09-29

## Context
The app runs only on developer machines. The user wanted it containerised so the host needs no Ruby toolchain and every worktree runs the same image.

## Decision
No deployment target. Development runs through `compose.yaml` with a `web` and a `jobs` service built from `Dockerfile.dev`; gems live in one shared named volume. Kamal was skipped; the generated production `Dockerfile` is kept unused.

## Consequences
- Every command runs as `docker compose run --rm web <cmd>`.
- `PORT` in `.env` is the only per-worktree setting. Orca copies `.env` into new worktrees via `.worktreeinclude`.
- Mail in development is written to `tmp/mails` (`delivery_method = :file`); no SMTP anywhere.
- CI runs in GitHub Actions once a remote exists; the backend doc's deploy-time rules (`force_ssl`, `config.hosts`, error tracking) do not apply.
