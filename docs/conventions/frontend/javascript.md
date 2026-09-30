# Stimulus & JS stack

Read when adding or changing JS behaviour.

Owns: controller conventions, JS stack.
Not here: widget CSS → [page-layout.md](page-layout.md).

## Stack

- Propshaft. Files served as-is, fingerprinted. No transforms.
- importmap-rails. Pins in `config/importmap.rb`; entry `app/javascript/application.js`. Vendored libraries in `vendor/javascript/`. No Node, no bundler.
- Turbo + Stimulus.
- No inline JS in views: no `<script>`, no `on*` attribute, no `href="javascript:"`. CSP blocks all three. The importmap tag in the layout carries the nonce and is the only exception.
- No global functions on `window`.

## Registration

Automatic: `controllers/index.js` calls `eagerLoadControllersFrom`, `importmap.rb` has `pin_all_from "app/javascript/controllers"`. Filename is the identifier: `enhanced_select_controller.js` → `data-controller="enhanced-select"`.

`app/javascript/controllers/` is the inventory. This file is the rules.

## Write a controller for

- Behaviour that must survive Turbo navigation.
- Wrapping a third-party widget so views never name the library.

## Don't write one when

- A native element covers it: `<details>` for disclosure, `<dialog>` for modals. Write the thin wrapper, not a reimplementation.
- A Rails built-in covers it: `disable_with`, `turbo_confirm`, `button_to`, Turbo Frames.
- CSS covers it: hover, focus, open/closed.

## Naming

After the UI concept or the behaviour. Never after a page. Never after the library.

- Concept: `enhanced-select`, `sortable-table`, `flash`.
- Behaviour: `frame-filter`, `auto-submit`, `reveal`.

## Granularity

- Per field, on the control: `enhanced-select`, `enhanced-date`.
- Per component: `sortable-table`, `flash`, `dialog`.
- App singleton, one instance in the layout: `navbar`, `loading-overlay`.

No controller orchestrates a page. Stack controllers on one element where behaviours combine.

## Markup contract

- Every controller file opens with a comment stating its markup contract: targets, values, actions, outlets.
- `static values` / `static targets` for anything the view supplies.
- Page-level state as values, per-element state as action params. Stimulus camelizes params; map to snake_case explicitly when posting to Rails.
- Controllers reach each other through outlets. The target controller exposes a method; its internals are not poked.
- `data-action` in the view over `addEventListener` in the controller.
- Global listeners declaratively: `data-action="click@window->x#close"`.
- Anything registered in `connect()` is unregistered in `disconnect()`.

## Wrapping a library

- `import` the pin at module top; read the object off `window` for UMD bundles.
- Guard double-init on Turbo reconnect.
- Destroy the instance in `disconnect()`.
- Library config in module constants above the class. The view supplies intent; the controller translates.

## Enhanced fields

Attach per field in the view. No auto-wiring, no global sweep.

| Field | Attach |
|---|---|
| `<select>` | `data-controller="enhanced-select"` |
| date / time / datetime | `data-controller="enhanced-date"` |

Libraries behind them are named in `DECISIONS.md`, not here.
