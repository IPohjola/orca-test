#!/usr/bin/env bash
# Documentation reconciliation hook.
#
#   baseline  (SessionStart) — records HEAD so mid-session commits still count
#   check     (Stop)         — maps the session's changed files to governing docs
#                              and asks for an explicit reconcile
#
# Scope: everything since the baseline commit, committed and uncommitted.
# Also flags hard invariants the docs state. Fires once per finding-set per session.
#
# Keep the path→doc table below in sync with docs/README.md.

set -uo pipefail

mode="${1:-check}"
payload=$(cat 2>/dev/null || echo '{}')
session=$(printf '%s' "$payload" | jq -r '.session_id // "nosession"' 2>/dev/null || echo nosession)

root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$root" 2>/dev/null || exit 0

basefile="${TMPDIR:-/tmp}/claude-doc-reconcile-${session}.base"

if [ "$mode" = "baseline" ]; then
  git rev-parse HEAD >"$basefile" 2>/dev/null
  exit 0
fi

base=""
if [ -f "$basefile" ]; then
  candidate=$(cat "$basefile" 2>/dev/null)
  if [ -n "$candidate" ] && git cat-file -e "${candidate}^{commit}" 2>/dev/null; then
    base="$candidate"
  fi
fi

changed=$(git status --porcelain 2>/dev/null | cut -c4- | sed 's/.* -> //')
if [ -n "$base" ]; then
  changed=$(printf '%s\n%s' "$changed" "$(git diff --name-only "$base" HEAD 2>/dev/null)")
fi
changed=$(printf '%s' "$changed" | sed '/^$/d' | sort -u)
[ -z "$changed" ] && exit 0

findings=""
add() {
  case "${findings}" in
    *"$1"*) ;;
    *) findings="${findings}$1"$'\n' ;;
  esac
}

# --- changed path -> governing doc -------------------------------------------
while IFS= read -r f; do
  [ -z "$f" ] && continue
  case "$f" in
    docs/*|CLAUDE.md|.claude/*) continue ;;
  esac
  case "$f" in
    app/javascript/*)                       add "docs/conventions/frontend/javascript.md" ;;
    app/assets/stylesheets/theme.css)       add "docs/conventions/frontend/tokens.md" ;;
    app/assets/stylesheets/common/*)        add "docs/conventions/frontend/page-layout.md" ;;
    app/assets/stylesheets/application.css) add "docs/conventions/frontend/page-layout.md" ;;
    app/views/layouts/*)                    add "docs/conventions/frontend/page-layout.md" ;;
    app/form_builders/*)                    add "docs/conventions/frontend/forms.md" ;;
    config/initializers/field_error_proc.rb) add "docs/conventions/frontend/forms.md" ;;
    app/controllers/*)                      add "docs/conventions/backend.md — Controllers, Authorization" ;;
    app/models/roles.rb)                    add "docs/conventions/backend.md — Authorization" ;;
    app/models/*|db/migrate/*)              add "docs/conventions/backend.md — Models, Schema" ;;
    app/jobs/*|app/mailers/*)               add "docs/conventions/backend.md — Jobs" ;;
    config/settings.yml|config/environments/*|config/initializers/*) add "docs/conventions/backend.md — Configuration" ;;
    spec/*)                                 add "docs/conventions/specs.md" ;;
  esac
done <<EOF
$changed
EOF

# --- hard invariants, added lines only ----------------------------------------
added=$(git diff "${base:-HEAD}" -- 'app/views' 2>/dev/null | grep '^+' | grep -v '^+++' || true)

printf '%s' "$added" | grep -qE '<script(>|[[:space:]])' \
  && add 'INVARIANT: a view gained an inline <script>. docs/conventions/frontend/javascript.md: behaviour goes in a Stimulus controller.'

printf '%s' "$added" | grep -qE '[[:space:]]on[a-z]+=' \
  && add 'INVARIANT: a view gained an on* handler attribute. docs/conventions/frontend/javascript.md.'

printf '%s' "$added" | grep -qE '[[:space:]]style=' \
  && add 'INVARIANT: a view gained a style attribute. docs/conventions/frontend/page-layout.md.'

printf '%s' "$added" | grep -qE 'deliver_now' \
  && add 'INVARIANT: deliver_now added. docs/conventions/backend.md — Jobs.'

[ -z "$findings" ] && exit 0

state="${TMPDIR:-/tmp}/claude-doc-reconcile-${session}.state"
sig=$(printf '%s' "$findings" | shasum | cut -d' ' -f1)
[ -f "$state" ] && [ "$(cat "$state" 2>/dev/null)" = "$sig" ] && exit 0
printf '%s' "$sig" >"$state"

jq -nc --arg f "$findings" '{
  decision: "block",
  reason: (
    "Documentation reconciliation (CLAUDE.md).\n\n" +
    "This session changed code governed by:\n\n" + $f + "\n" +
    "Compare the change against each doc and resolve explicitly:\n" +
    "  - Doc right, code wrong -> fix the code.\n" +
    "  - Doc stale -> update it, and say so.\n" +
    "  - Deliberate change of direction -> say so and confirm before editing the doc.\n\n" +
    "Never rewrite a doc to match your own change silently. " +
    "If everything already agrees, say so in one line and stop."
  )
}'
