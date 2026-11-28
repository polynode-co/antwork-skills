#!/usr/bin/env bash
# Builds the Perplexity plugin: perplexity/antwork/, committed so Perplexity's
# "Import plugin from GitHub" can take its folder URL, and zipped for "Upload
# plugin or skill".
#
# Perplexity (help page "Create or upload a custom plugin", read 2026-11-28)
# wants `plugin.json` at the plugin's root with a `name`, each skill as a
# folder holding a SKILL.md with `name` and `description` in its YAML, and MCP
# servers in `mcp.json` with an HTTPS `url` and a `type`. It skips, without
# failing the upload, any server that has fixed headers or no `type`, which is
# why the repo's own .mcp.json (X-Antwork-Install header) and mcp.json (no
# type) cannot be reused. So this server entry has `type` and no headers:
# Perplexity's Connect button runs Antwork's OAuth, and its registration name
# already says which client connected.
#
# Generated from skills/ (copied as they are) and .claude-plugin/plugin.json
# (name, version, description), so the package cannot drift from the Claude
# Code plugin. Never edit perplexity/antwork/ by hand.
#
#   perplexity/build.sh               -> rewrites perplexity/antwork/
#   perplexity/build.sh --check       -> fails if perplexity/antwork/ is stale
#   perplexity/build.sh --zip <file>  -> writes the upload ZIP of a fresh build
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/perplexity/antwork"
MCP_URL="https://api.antwork.io/mcp"

# Perplexity's limits for one plugin.
MAX_SKILLS=32
MAX_FILES=1000
MAX_BYTES=$((20 * 1024 * 1024))
MAX_DESCRIPTION=1024

mode="write"
zip_path=""
case "${1:-}" in
  "") ;;
  --check) mode="check" ;;
  --zip)
    mode="zip"
    zip_path="${2:?--zip needs an output path}"
    ;;
  *)
    echo "usage: perplexity/build.sh [--check | --zip <file>]" >&2
    exit 2
    ;;
esac

STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT
PLUGIN="$STAGE/antwork"
mkdir -p "$PLUGIN/skills"

# plugin.json: only the fields Perplexity documents plus the plain metadata
# every plugin manifest carries. Claude Code's `agents` list and `$schema` stay
# out; the audit's agent files still ride along inside its skill folder.
jq '{name, displayName, description, version, author, homepage, repository, license}' \
  "$ROOT/.claude-plugin/plugin.json" > "$PLUGIN/plugin.json"

description="$(jq -r .description "$PLUGIN/plugin.json")"
if [ "${#description}" -gt "$MAX_DESCRIPTION" ]; then
  echo "plugin description is ${#description} chars; Perplexity allows $MAX_DESCRIPTION" >&2
  exit 1
fi

jq -n --arg url "$MCP_URL" '{mcpServers: {antwork: {type: "http", url: $url}}}' > "$PLUGIN/mcp.json"

for dir in "$ROOT"/skills/*/; do
  name="$(basename "$dir")"
  skill="$dir/SKILL.md"
  [ -f "$skill" ] || { echo "skills/$name has no SKILL.md" >&2; exit 1; }
  # The frontmatter's name must match the folder and a description must be there.
  fm="$(awk 'NR==1 && $0=="---" {fm=1; next} fm && $0=="---" {exit} fm' "$skill")"
  grep -qx "name: $name" <<<"$fm" || { echo "skills/$name/SKILL.md: name is not $name" >&2; exit 1; }
  grep -q '^description: .' <<<"$fm" || { echo "skills/$name/SKILL.md has no description" >&2; exit 1; }
  cp -R "${dir%/}" "$PLUGIN/skills/$name"
done
# Finder litter in a local checkout is not part of any skill.
find "$PLUGIN" -name .DS_Store -delete

skills="$(find "$PLUGIN/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
files="$(find "$PLUGIN" -type f | wc -l | tr -d ' ')"
bytes="$(find "$PLUGIN" -type f -exec cat {} + | wc -c | tr -d ' ')"
[ "$skills" -le "$MAX_SKILLS" ] || { echo "$skills skills; Perplexity allows $MAX_SKILLS" >&2; exit 1; }
[ "$files" -le "$MAX_FILES" ] || { echo "$files files; Perplexity allows $MAX_FILES" >&2; exit 1; }
[ "$bytes" -le "$MAX_BYTES" ] || { echo "$bytes bytes; Perplexity allows $MAX_BYTES" >&2; exit 1; }

case "$mode" in
  check)
    if ! diff -r "$PLUGIN" "$OUT" >/dev/null 2>&1; then
      diff -r "$PLUGIN" "$OUT" >&2 || true
      echo "perplexity/antwork/ is stale: run perplexity/build.sh and commit the result" >&2
      exit 1
    fi
    echo "perplexity/antwork/ is up to date ($skills skills, $files files)"
    ;;
  zip)
    # plugin.json at the ZIP's root, as the upload expects. Fixed mtimes, so an
    # unchanged tree builds a byte-identical ZIP.
    mkdir -p "$(dirname "$zip_path")"
    out_abs="$(cd "$(dirname "$zip_path")" && pwd)/$(basename "$zip_path")"
    rm -f "$out_abs"
    find "$PLUGIN" -exec touch -t 202601010000 {} +
    (cd "$PLUGIN" && find . -type f | sed 's|^\./||' | LC_ALL=C sort | zip -qX -@ "$out_abs")
    echo "$out_abs"
    ;;
  write)
    rm -rf "$OUT"
    cp -R "$PLUGIN" "$OUT"
    echo "perplexity/antwork/ ($skills skills, $files files)"
    ;;
esac
