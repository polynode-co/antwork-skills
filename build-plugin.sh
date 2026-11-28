#!/usr/bin/env bash
# Builds plugin/, the Claude plugin folder that the Claude Directory reads and
# that .claude-plugin/marketplace.json installs.
#
# The Directory scans everything in the plugin folder and refuses repo files
# such as CLAUDE.md, scripts and other clients' manifests. So the plugin gets
# its own folder, and only the files it loads go in it. skills/ at the root
# stays the one source, because Cursor, Codex, the skills CLI, install.sh and
# the claude.ai build all read it there.
#
# Copied in, never edited by hand (this script owns them):
#   plugin/skills/                  <- skills/
#   plugin/.mcp.json                <- .mcp.json
#   plugin/LICENSE                  <- LICENSE
#   plugin/.claude-plugin/icon.png  <- assets/icon.png (the Directory's listing icon)
# Edited by hand: plugin/.claude-plugin/plugin.json and plugin/README.md.
#
#   ./build-plugin.sh          rewrite the copied files
#   ./build-plugin.sh --check  fail if they differ from the sources (CI)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
PLUGIN="$ROOT/plugin"

build_into() {
  local out="$1"
  rm -rf "$out/skills"
  mkdir -p "$out/.claude-plugin"
  cp -R "$ROOT/skills" "$out/skills"
  find "$out/skills" \( -name .DS_Store -o -name Thumbs.db \) -delete
  cp "$ROOT/.mcp.json" "$out/.mcp.json"
  cp "$ROOT/LICENSE" "$out/LICENSE"
  cp "$ROOT/assets/icon.png" "$out/.claude-plugin/icon.png"
}

if [ "${1:-}" = "--check" ]; then
  STAGE="$(mktemp -d)"
  trap 'rm -rf "$STAGE"' EXIT
  build_into "$STAGE"
  status=0
  diff -r "$STAGE/skills" "$PLUGIN/skills" || status=1
  for f in .mcp.json LICENSE .claude-plugin/icon.png; do
    cmp -s "$STAGE/$f" "$PLUGIN/$f" || { echo "plugin/$f differs from its source" >&2; status=1; }
  done
  for f in .claude-plugin/plugin.json README.md; do
    [ -f "$PLUGIN/$f" ] || { echo "plugin/$f is missing" >&2; status=1; }
  done
  if [ "$status" -ne 0 ]; then
    echo "plugin/ is stale: run ./build-plugin.sh and commit the result" >&2
    exit 1
  fi
  echo "plugin/ is up to date"
  exit 0
fi

build_into "$PLUGIN"
echo "built plugin/"
