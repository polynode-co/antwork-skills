# Antwork: post to LinkedIn, X, Instagram and more from your AI

[![skills.sh](https://skills.sh/b/polynode-co/antwork-skills)](https://skills.sh/polynode-co/antwork-skills)

**AI assistants have no built-in connector for posting to social media.** To let your assistant draft, schedule and publish posts, you connect it to an MCP server that holds the platform permissions. [Antwork](https://antwork.io?utm_source=github&utm_medium=readme&utm_campaign=antwork_skills) is that server: connect `https://api.antwork.io/mcp` once, sign in with OAuth, and your assistant can post to your connected accounts on **LinkedIn (personal profile or company page), X, Instagram, Facebook Pages, Threads, TikTok, YouTube, Pinterest, Bluesky, Mastodon, Discord, Telegram, Slack and Google Business Profile**. Posts stay drafts until you ask it to schedule or publish them.

It works in VS Code (GitHub Copilot chat), Claude, ChatGPT, Cursor, Cline and any other client that speaks MCP. The free plan covers 2 social accounts and 10 posts a month with no card; paid plans start at $19 a month ([pricing](https://antwork.io/pricing?utm_source=github&utm_medium=readme&utm_campaign=antwork_skills)).

## Install in one line

Pick your agent. Each line adds the Antwork skills (including [`/antwork ship`](skills/antwork-ship/SKILL.md), which turns your commits and releases into posts); the plugin lines also connect the MCP server.

| Agent | Command |
|---|---|
| **Claude Code** (plugin: skills, audit agents and MCP server) | `/plugin marketplace add https://github.com/polynode-co/antwork-skills.git` then `/plugin install antwork@antwork` |
| **Codex** (plugin: skills and MCP server) | `codex plugin marketplace add polynode-co/antwork-skills && codex plugin add antwork@antwork && codex mcp login antwork` |
| **Any agent, skills only** ([skills CLI](https://skills.sh): Claude Code, Codex, Cursor and others) | `npx skills add polynode-co/antwork-skills` |

The skills CLI installs skills, not MCP servers, so connect the server once yourself:

```sh
# Claude Code
claude mcp add --transport http antwork https://api.antwork.io/mcp
# Codex
codex mcp add antwork --url https://api.antwork.io/mcp && codex mcp login antwork
```

Or in Codex's `~/.codex/config.toml`:

```toml
[mcp_servers.antwork]
url = "https://api.antwork.io/mcp"
```

Then, from inside a repo: `/antwork ship` (or just "post about what I shipped this week").

## Connect

| | |
|---|---|
| Server URL | `https://api.antwork.io/mcp` |
| Server name | `antwork` |
| Transport | Streamable HTTP |
| Auth | OAuth 2.1 with dynamic client registration. No API key to create or store. |

The first tool call opens a consent screen in your browser. After that, ask your assistant to connect a social account and it returns a connect link for each platform.

### VS Code

Install **Antwork** from the MCP servers gallery, or [add it in one click](https://antwork.io/automate/vscode?utm_source=github&utm_medium=readme&utm_campaign=antwork_skills). MCP servers in VS Code run through GitHub Copilot, so the Copilot extension must be installed and signed in. To add it by hand, put this in `.vscode/mcp.json`:

```json
{
  "servers": {
    "antwork": {
      "type": "http",
      "url": "https://api.antwork.io/mcp"
    }
  }
}
```

### Other clients

- **Claude.ai or Claude Desktop:** add `https://api.antwork.io/mcp` as a custom connector. [Step-by-step](https://antwork.io/automate/claude-desktop/linkedin?utm_source=github&utm_medium=readme&utm_campaign=antwork_skills). For the calendar, campaign, analytics and audit workflows, add the [claude.ai skill](#claudeai) too.
- **Claude Code:** install the plugin below, which connects the server and adds the skills in one step.
- **ChatGPT:** [setup guide](https://antwork.io/automate/chatgpt?utm_source=github&utm_medium=readme&utm_campaign=antwork_skills).
- **Cursor, and Grok Bot through Cursor's catalog:** this repo is also a Cursor plugin (`.cursor-plugin/` and `mcp.json`: the server plus the skills). Until it is listed in the Cursor Marketplace, use the [setup guide](https://antwork.io/automate/cursor?utm_source=github&utm_medium=readme&utm_campaign=antwork_skills), or give Grok Bot the server URL ([guide](https://antwork.io/automate/grok-bot?utm_source=github&utm_medium=readme&utm_campaign=antwork_skills)).
- **Cline:** open MCP Servers → **Remote Servers**, enter the name `antwork`, the URL `https://api.antwork.io/mcp` and transport **Streamable HTTP**, click **Add Server**, then sign in when your browser opens. Or put this in `cline_mcp_settings.json`: `{"mcpServers": {"antwork": {"type": "streamableHttp", "url": "https://api.antwork.io/mcp"}}}`. Step by step for agents: [llms-install.md](llms-install.md).
- **Anything else:** point it at the server URL above. [Full MCP docs](https://antwork.io/docs/mcp?utm_source=github&utm_medium=readme&utm_campaign=antwork_skills).

### What your assistant can do

- Draft a post in each account's own voice. It reads that account's recent posts first.
- Schedule or publish, per account or as a campaign across several accounts.
- Attach images, video and PDFs, and manage the media library.
- See the calendar, list and search posts, and retry a failed one.
- Report performance per post and per account: impressions or views, likes, comments, shares and reach, plus saves, link clicks, profile visits, follows and watch time where the platform reports them, and daily follower counts per connected account. A metric a platform doesn't report shows as blank, never as zero.

Each platform's own rules apply: Instagram and Pinterest need an image or video, TikTok and YouTube need a video, and Instagram needs a Creator or Business account. [Tool reference](https://antwork.io/docs/mcp/tools?utm_source=github&utm_medium=readme&utm_campaign=antwork_skills).

## Antwork Skills for Claude Code and claude.ai

This repo also adds [Agent Skills](https://docs.claude.com/en/docs/agents-and-tools/agent-skills) on top of the connector. The connector alone handles single steps: drafting, scheduling, publishing, media, connections. The skills cover the multi-step workflows: a content calendar planned around what's already scheduled, one piece repurposed across platforms, one long video cut into captioned Shorts, a campaign arc, ideas grounded in what performed, variations on what went viral in your niche, an analytics report, and a scored audit. One router sends `/antwork <command>` (or a plain request) to the right one.

### Commands

| Command | Skill | What it does |
|---|---|---|
| `/antwork voice [account]` | [`antwork-voice`](skills/antwork-voice/SKILL.md) | Read an account's voice from its real posts, or capture one from samples. |
| `/antwork calendar <theme>` | [`antwork-calendar`](skills/antwork-calendar/SKILL.md) | Plan and batch-schedule a content calendar. |
| `/antwork repurpose <source>` | [`antwork-repurpose`](skills/antwork-repurpose/SKILL.md) | One piece → one post with a native version per platform. |
| `/antwork clip <video>` | [`antwork-clip`](skills/antwork-clip/SKILL.md) | One long video → captioned vertical clips, cut locally with ffmpeg, each drafted for YouTube Shorts, TikTok, Instagram Reels and Facebook. |
| `/antwork campaign <goal>` | [`antwork-campaign`](skills/antwork-campaign/SKILL.md) | Sequence a multi-post campaign / launch week. |
| `/antwork ideas [topic]` | [`antwork-ideas`](skills/antwork-ideas/SKILL.md) | Data-driven hooks grounded in what already performed. |
| `/antwork viral <niche or @creator>` | [`antwork-viral`](skills/antwork-viral/SKILL.md) | Study what went viral in a niche or for a creator, name the patterns, write variations in your voice. |
| `/antwork analytics [range]` | [`antwork-analytics`](skills/antwork-analytics/SKILL.md) | Pull performance + engagement and synthesize a report. |
| `/antwork audit` | [`antwork-audit`](skills/antwork-audit/SKILL.md) | Full social-presence audit with 5 parallel agents + a 0-100 Social Health Score. |
| `/antwork ship [--since …] [--release <tag>]` | [`antwork-ship`](skills/antwork-ship/SKILL.md) | Turn the current repo's commits, merged PRs or a release into build-in-public posts, per account, in each account's voice. |

You don't have to type the command — describe the intent ("plan next week", "how did last month do?") and the [router](skills/antwork/SKILL.md) picks the skill. A single post, connecting an account and media need no skill: the connector's own instructions cover them.

### The audit's parallel agents

In Claude Code, `/antwork audit` spawns five read-only subagents concurrently, then synthesizes a weighted score. On claude.ai, which has no subagents, the same five dimensions run one after another:

| Agent | Dimension | Weight |
|---|---|---|
| [`antwork-performance`](skills/antwork-audit/agents/antwork-performance.md) | Engagement & top/bottom posts | 30% |
| [`antwork-voice-analyst`](skills/antwork-audit/agents/antwork-voice-analyst.md) | Voice consistency across accounts | 20% |
| [`antwork-cadence`](skills/antwork-audit/agents/antwork-cadence.md) | Posting cadence & timing | 20% |
| [`antwork-content`](skills/antwork-audit/agents/antwork-content.md) | Content quality (hooks, CTAs, fit) | 20% |
| [`antwork-growth`](skills/antwork-audit/agents/antwork-growth.md) | Platform coverage & growth | 10% |

### Prerequisite

The skills call the Antwork MCP server, so it has to be connected (see [Connect](#connect)). The plugin does that for you. A single OAuth token spans all your workspaces.

Once connected, a good first run is **audit** (where you stand), then **ideas** or **calendar** (what to post next).

### Install the skills

#### Claude Code plugin (recommended)

This repo is also a Claude Code **plugin marketplace**. Installing the plugin wires up the Antwork MCP server *and* all skills + agents in one step:

```sh
/plugin marketplace add https://github.com/polynode-co/antwork-skills.git
/plugin install antwork@antwork
```

That's it — the [`antwork` MCP server](plugin/.mcp.json) connects automatically (complete the OAuth prompt), and the router, 10 skills, and 5 audit agents load. Why the plugin over loose skills: the skills are useless until Antwork's MCP is connected, and the plugin ships that config bundled, so there's no separate connector setup.

#### Script install (no plugin)

If you'd rather not use the plugin system, the script copies the skills + agents straight into `~/.claude/` (you still connect the [Antwork MCP](https://antwork.io?utm_source=github&utm_medium=readme&utm_campaign=antwork_skills) yourself):

```sh
curl -fsSL https://raw.githubusercontent.com/polynode-co/antwork-skills/main/install.sh | bash
```

Prefer to clone first? `git clone … && cd antwork-skills && ./install.sh`. Remove everything with `./uninstall.sh`.

#### OpenClaw

`clawhub/antwork/` is a **self-contained** skill for OpenClaw. A [ClawHub](https://clawhub.ai) listing is coming soon; it is not published there yet, so `clawhub install` won't find it. Until then, install it by hand: copy the folder into your OpenClaw skills directory and connect the server.

```sh
git clone https://github.com/polynode-co/antwork-skills.git
cp -r antwork-skills/clawhub/antwork ~/.openclaw/skills/antwork
mcporter config add antwork --url https://api.antwork.io/mcp --auth oauth
```

It is deliberately not the router above. ClawHub publishes one folder, so a skill that routes to 10 siblings that were never installed would be broken — this one inlines the setup, the drafting protocol, the character limits and the draft→publish two-step in a single file.

#### claude.ai

claude.ai and Cowork install plugins from the Claude Directory (**Customize > Plugins**). This plugin is not listed there yet, so until it is, claude.ai gets the same skills as one upload:

1. Download [`antwork-claude-ai-skill.zip`](https://github.com/polynode-co/antwork-skills/releases/download/claude-ai-skill/antwork-claude-ai-skill.zip).
2. In claude.ai, open Settings, find Skills, and upload the ZIP.
3. Connect the Antwork connector (see [Connect](#connect)) if you haven't.

It is one skill named `antwork`: the router, with every other skill and audit dimension inside it as a reference file it reads when needed. [`claude-ai/build.sh`](claude-ai/build.sh) generates it from `skills/` (each skill with its templates, and the audit's agents), and a workflow republishes it on every change, so it never drifts from the plugin. Posting itself needs no skill on claude.ai either: the connector sends its drafting rules when it connects.

## What the plugin runs and sends

The plugin is the [`plugin/`](plugin) folder: the skills, five audit agents and one MCP server entry. It has no hooks, no scripts that start on their own, no bundled programs and no package installs. Its [README](plugin/README.md) lists everything it runs and sends: the one server (`https://api.antwork.io/mcp`, with an `X-Antwork-Install` header naming this plugin), the read-only git commands in `/antwork ship`, the local ffmpeg and transcriber steps in `/antwork clip`, and uploads to `api.antwork.io` only.

## Repository layout

```
antwork-skills/
├── skills/                   # router + 10 specialized skills: the one source, each with its own templates/
│   ├── antwork/              # router — /antwork <command>
│   ├── antwork-ship/         # commits / PRs / releases → posts
│   ├── antwork-calendar/     ├── antwork-campaign/
│   ├── antwork-repurpose/    ├── antwork-ideas/
│   ├── antwork-voice/        ├── antwork-analytics/
│   ├── antwork-viral/        ├── antwork-clip/
│   └── antwork-audit/        # + agents/: the 5 parallel audit subagents
├── plugin/                   # the Claude plugin (Claude Code, the Claude Directory)
│   ├── .claude-plugin/plugin.json   # plugin manifest (edited here)
│   ├── README.md             # the plugin's own README, shown in the Directory (edited here)
│   └── skills/, .mcp.json, LICENSE, icon   # copied by build-plugin.sh; never edit by hand
├── build-plugin.sh           # refreshes plugin/ from skills/; --check in CI
├── .claude-plugin/marketplace.json  # self-hosted marketplace: lists ./plugin
├── .mcp.json                 # Antwork MCP server (copied into plugin/)
├── .cursor-plugin/ + mcp.json  # Cursor plugin: the server plus skills/
├── claude-ai/build.sh        # builds the claude.ai ZIP from skills/
├── clawhub/                  # self-contained OpenClaw skill (ClawHub listing coming soon)
├── install.sh / uninstall.sh # script-install fallback
├── llms-install.md           # how an agent (Cline) adds the server
├── docs/                     # directory submission answers
├── assets/                   # icons
└── README.md / LICENSE
```

## Contributing

Each skill lives in `skills/<name>/SKILL.md` with YAML frontmatter (`name`, `description`) followed by markdown instructions. Keep `description:` specific — it determines when Claude auto-loads the skill. Use only [real Antwork MCP tools](https://antwork.io?utm_source=github&utm_medium=readme&utm_campaign=antwork_skills) and never invent tool arguments; the server rejects unknown fields. After changing `skills/`, run `./build-plugin.sh` and commit `plugin/` too; CI fails while it is stale.

## License

[MIT](LICENSE)
