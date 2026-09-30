# Forms

Read when building or changing a form.

Owns: form row structure, field markup, required and error conventions.
Class definitions → [page-layout.md](page-layout.md). Widget behaviour → [javascript.md](javascript.md).

## Builders

- `form_with` only. `model:` for records, `url:` for filters.
- Default builder `ApplicationFormBuilder` adds `required-field` to a label when the attribute has an unconditional presence validation.
- `f.submit` with `disable_with`. Cancel is a `link_to`, never a button with a handler.

## Row structure

- One row: `<div class="inline-field-group inline-field-group--equal inline-field-group--stack">`. All three classes on every row, including checkbox rows.
- Each control: `<div class="inline-field">` holding `<label>`, optional `.instructions`, one control.
- Checkbox item: `<div class="checkbox-with-label">`.
- Button row: `<div class="action-group action-group--stack">`.
- Several elements in one control slot: `.control-stack`.
- Labels are self-contained. No heading text between rows carrying shared wording.
- No per-form field classes. A shape the shared classes cannot express becomes a modifier in `common/forms.css`.

## Inputs

- Select: `f.select` / `f.collection_select` + `data: { controller: "enhanced-select" }`.
- Date, time, datetime: `f.date_field` etc. + `data: { controller: "enhanced-date" }`.
- Rich text: `f.rich_text_area`.

## Required

- Label class `required-field`. The marker is its `::after`. Never write `*` into label text.
- Never the HTML `required` attribute: enhanced widgets hide the native control. Validation is server-side.
- Filter forms with `label_tag`: pass `class: "required-field"` by hand; reject in a `before_action` with flash and redirect.

## Errors

- Model form failure: re-render with `status: :unprocessable_entity`. `field_error_proc` wraps each invalid control with `aria-invalid`, `aria-describedby` and the message in flow.
- Errors on `:base` or virtual keys: flash, via a shared controller helper.

## Dependent selects

No page JS. The child select renders inside a `turbo_frame_tag` with a `frame_id:` local; the parent select carries the generic `frame-filter` controller; the controller action re-renders the partial with the same `frame_id`.

## Conditional notices

Wrap the field group and the notice in one `data-controller` element. The notice is a sibling of the group, outside it, `hidden` by default.
