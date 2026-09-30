# 003 — Authorization mechanism

**Date:** 2026-09-29

## Context
Four roles with distinct reach: `admin`, `instructor`, `customer` (a youth), `customer_custodian` (linked to a youth, may message the youth's instructor but not read the youth's data). Rules must be pinned by a spec from the first controller.

## Decision
Role callbacks per `docs/conventions/backend.md` → Authorization, with `Roles` constants in `app/models/roles.rb` and `spec/requests/authorization_matrix_spec.rb` classifying every routed action. Role order weakest to strongest: `customer_custodian`, `customer`, `instructor`, `admin`. Column default is the weakest role.

## Consequences
- Every new controller declares its role set and skips `require_role_declared`, or is denied.
- Per-record reach (custodian → linked youth → assigned instructor) is expressed as `visible_*` scopes in controllers.
- A policy library is adopted only if those scopes cannot express a rule; the ADR that adopts it names the rule.
