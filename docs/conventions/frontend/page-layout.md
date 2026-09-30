# Page layout & shared styles

Read when building a page, touching a layout or shared CSS.

Owns: stylesheet organisation, shared-CSS contracts, page composition.
Not here: form rows → [forms.md](forms.md). Nav → [navigation.md](navigation.md). Tokens → [tokens.md](tokens.md). JS → [javascript.md](javascript.md).

## Stylesheets

- `theme.css` — tokens.
- `application.css` — the only entry. One `@import` per stylesheet. No `stylesheet_link_tag` in a view. Vendor CSS imports into `layer(vendor)` so unlayered project rules win regardless of order.
- `common/<component>.css` — one file per shared component, named after it. `layout.css` holds page primitives, `utilities.css` holds helpers and button rows.
- `<controller>.css` — per-controller styles. Imported in `application.css` on creation.
- `print.css` — the only `@media print` block. The bundle links `media: "all"`.
- No `style` attributes in views. No hardcoded widths, colours, weights or spacing: tokens only.
- CSS nesting at most three levels, and only where the parent-child relation is not obvious from class names.
- Prefer box-model adjustments over absolutely positioned pseudo-elements.

## Contracts

- Field state travels as custom properties, not state selectors. Error sets `--field-border-error`; hover/focus/disabled set `--field-border-state`; the surface rule resolves them by `var()` fallback order. No specificity fights.
- A field's error message is emitted by `field_error_proc`, in flow under the control, always visible. Never written in a view.
- Table corner radii come from corner cells, not `overflow: hidden`, so dropdowns inside cells are not clipped.
- A horizontal-scroll wrapper clips dropdowns. Never wrap a table containing form controls in one.
- Modals are `<dialog>`. Top layer, no `z-index`, no overlay div.
- Container queries for CTA button rows; media query for form rows. Do not mix: `container-type` breaks flex fill in equal-column rows.

## Page composition

1. `<h1 class="page-title">` outside all bands.
2. `<%= back_link ... %>` if any, immediately after the `<h1>`.
3. One `<%= render "layouts/page_section" do %>` block per logical section. Sibling calls produce sibling bands.

Rules:

- Use `layouts/page_section`. Never open-code the section/div pair.
- Band backgrounds alternate automatically. Force with `.page-band--surface` / `.page-band--page` only when alternation lands wrong.
- Bands own vertical padding. No top/bottom margin on a section's outermost content.

## Flash

One `#flash` region in the layout rendering `layouts/_flash`. Turbo Stream responses that set flash re-render it: `turbo_stream.update("flash", partial: "layouts/flash")`.

## Icons

Inline SVG partials in `app/views/shared/icons/_<name>.html.erb`. `render "shared/icons/<name>", size: 20`.
