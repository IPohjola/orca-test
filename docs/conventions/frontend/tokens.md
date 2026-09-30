# Tokens & sizing

Read when adding a token or picking a unit.

`theme.css` is the token inventory. This file is the rules.

## Two layers

- Palette (`--palette-*`): raw values by family (neutral, accent, danger, success, warning). Numbers track lightness: higher is lighter. A one-value family uses 500.
- Semantic (`--color-*`, `--font-*`, `--spacing-*`, `--border-*`, `--shadow-*`, `--z-*`): purpose-named, pointing into the palette.

Rules:

- Feature stylesheets reference semantic tokens only. Never palette tokens, never raw values.
- A state colour names the state and the property it paints: `--color-hover-border`, not `--color-accent-hover`.
- Only font weights the `@font-face` or import actually loads get a token.
- One corner radius, `--border-radius`. A second value needs a rule that says when.
- Adding a semantic token means adding it to `theme.css`. No aliasing in a feature stylesheet.
- A semantic token points at another semantic token only when the second name adds meaning.
- Z-index by tier from the ladder in `theme.css`. No ad-hoc numbers.
- Component tokens (`--input-height`, `--spacing-form`) sit in the component section of `theme.css`.

## Units

`rem` by default. `1rem = 16px`.

| Property | Unit |
|---|---|
| Font sizes, spacing, radii, layout widths and heights | `rem` |
| Border widths, shadow offsets, standalone icon sizes | `px` |
| `letter-spacing` | `em` |
| Anything that must follow the window | `vh` / `vw` |
| Proportional splits | `%`, flex, grid |

`em` only for an element that must scale with its component's local text size.
