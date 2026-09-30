# 001 — Database

**Date:** 2026-09-29

## Context
The app is a local test bed for the Orca parallel-worktree workflow and never deploys. Several checkouts run side by side on one machine, each needing its own database without shared server state.

## Decision
SQLite, one file per database under `storage/`, which is per checkout. Development uses `primary` and `queue`; test uses `harbor_test`.

## Consequences
- Every worktree gets isolated databases with no configuration. Only the host port differs.
- `spec/rails_helper.rb` checks the database basename ends in `_test` instead of the full name.
- No `DATABASE_URL`; the path lives in `config/database.yml`. Superseded by a new ADR if the app ever deploys.
