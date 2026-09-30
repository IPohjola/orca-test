# Navigation

Read when touching the header nav or a page's back link.

Owns: nav partials, nav helpers, the nav item data contract.

## Structure

Navigation is data: an array of item hashes in `app/views/layouts/_navigation.html.erb`, rendered by `layouts/_nav_item`. No markup per menu entry.

- `_nav_item` takes `label:` and `items:`. Filters by `permitted?(item[:roles])`, then: 0 visible → nothing; 1 → a single tab with the item's own label; 2+ → `_nav_dropdown`.
- `_nav_dropdown` takes pre-filtered `label:` + `items:`. `{ divider: true }` renders a separator; leading, trailing and consecutive dividers are dropped.

## Helpers

- `nav_item_selected?(item)` — current request matches `item[:controller]`; `action:` narrows, `not_action:` excludes.
- `permitted?(roles)` — `Current.user.role_in?(roles)`. Same constants the controller declares.
- `back_link(text, url = :back)` — renders the row after the `<h1>`. Block element.

## Item contract

```ruby
{
  label:      t("nav.items.x"),
  path:       x_path,
  controller: "x" | ["x", "y"],
  action:     "index" | [...],       # optional
  not_action: "edit" | [...],        # optional
  roles:      Roles::MANAGEMENT      # required; same constant as the controller
}
{ divider: true }
```
