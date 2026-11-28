# antwork-skills — Claude Code plugin for Antwork

A skill library that routes `/antwork <command>` to specialized skills, each encoding the
correct sequence of Antwork MCP tool calls. Distributed as a Claude plugin (`plugin/`, bundled
`.mcp.json` → `api.antwork.io/mcp`), listed in the Claude Directory from that folder, or via `install.sh`.

This repo is **prompt content, not code**. There are no dependencies and no test
suite (the only build copies files, below) — correctness means the instructions are accurate about Antwork's MCP tools.

## Layout

- `skills/<name>/SKILL.md` — one directory per skill; `SKILL.md` is the skill.
- `skills/<name>/templates/*.md` — output templates, inside the skill that renders them (since 1.3.0,
  so the skills CLI, which installs one skill folder at a time, carries them). `campaign-brief.md` lives
  in `antwork-campaign` and `antwork-repurpose` points at it there.
- `skills/antwork-audit/agents/*.md` — the 5 read-only audit subagents used by `/antwork audit`. The
  plugin lists them in `plugin/.claude-plugin/plugin.json` `agents`, which replaces the default `agents/` scan;
  add or rename an agent there too.
- `plugin/` — the Claude plugin, the folder the Claude Directory reads (plugin path `plugin`). Its
  `.claude-plugin/plugin.json` and `README.md` are edited there. Its `skills/`, `.mcp.json`, `LICENSE` and
  icon are copies made by `./build-plugin.sh`: **after any change to `skills/` or `.mcp.json`, run it and
  commit `plugin/`**; CI (`build-plugin.sh --check`) fails while it is stale. Never edit `plugin/skills/`.
  It is a separate folder because the Directory refuses repo files in a plugin (this `CLAUDE.md`, scripts,
  other clients' manifests), so nothing but what the plugin loads goes in it. Keep image file names and
  `curl … | sh` out of `plugin/`, and `$`-variables out of its agents, which the Directory scan flags.
- `.claude-plugin/marketplace.json` — the self-hosted marketplace; it lists `./plugin`.
- `install.sh` / `uninstall.sh` — non-plugin install path.
- `claude-ai/build.sh` — builds the claude.ai ZIP (one `antwork` skill; every other skill and
  agent becomes a file under `references/`). `.github/workflows/claude-ai-skill.yml` reruns it on
  every push to `main` that touches `skills/` or `claude-ai/` and replaces the asset on the
  `claude-ai-skill` release, whose URL antwork.io links to. Never rename that release or asset.
- `README.md` — the command table. **It must stay in sync with `skills/`.**

## Changing a skill

Applies to every change, by hand or unattended.

- **Base branch is `main`** — this repo has no `dev` branch. Branch from `main`, PR to `main`.
- Nothing to test; the one build is `./build-plugin.sh` (see Layout). Verification is by inspection; say so in the PR body rather
  than implying automated coverage.
- Raise `version` in `plugin/.claude-plugin/plugin.json` (and the two `.cursor-plugin/` manifests) with every
  change to the plugin: the Directory and existing installs only pick up a new version.
- **Never invent MCP tool names, parameters, or response shapes.** Every tool referenced in
  a skill must exist in the Antwork MCP server. If the issue requires a tool you cannot
  verify against `../antwork.io/agent-service/app/mcp/server.py`, stop and say so rather than
  guessing — a plausible-looking wrong tool name is worse than no change. The server's tools
  change: on 2026-08-24 the stored voice profile went (`prepare_voice_analysis`,
  `save_voice_analysis`, `voiceStale`), on 2026-10-03 eight tools were cut (antwork.io
  #1437), and on 2026-10-16 `whoami`, `get_workspace_settings`, `get_calendar`,
  `schedule_campaign`, `publish_campaign` and `retry_failed_post` were folded into
  `list_workspaces`, `get_post_context`, `list_posts`, `schedule_post` and `publish_post`,
  then `disconnect_social_account` went web-only (#1868), and on 2026-11-02 `create_campaign`
  was folded into `create_post(posts=[...])` (antwork.io #2425; 22 tools remain).
  Each time these skills went on naming tools that no longer existed.
- Facts with a source of truth get checked against it, not memory: character limits live in
  `../antwork.io/src/lib/platforms/common/platform-rules.json`.
- `clawhub/antwork/SKILL.md` is a self-contained copy of the core rules for OpenClaw. It is
  not listed on ClawHub yet (installed by hand, see README). A change to a rule in `skills/` usually needs the same change there.
- Adding or renaming a skill means updating **both** `skills/<name>/SKILL.md` and the command
  table in `README.md`. A PR touching only one is incomplete.
- Adding or removing a skill also means updating the `SKILLS` list in `install.sh` (a removed one
  goes on its retired list there, and stays in `uninstall.sh` so old installs get cleaned up).
  Otherwise never touch `install.sh`, `uninstall.sh`, or `.mcp.json` unless the issue explicitly asks.
- **Single steps belong to the server, not here.** Drafting one post, scheduling, media
  and connections are spelled out in the MCP server's `instructions=` and tool
  descriptions. A skill that restates them only drifts (antwork-poster, -setup, -media and
  -engage were removed in 1.2.0 for that reason). Skills here are for multi-step workflows.
