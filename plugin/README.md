# Antwork: plan, draft, schedule and publish social posts from Claude

[Antwork](https://antwork.io) connects Claude to your social accounts. Claude drafts each post in the voice of the account it's for, read from that account's own recent posts. It schedules or publishes only the posts you approve, to **LinkedIn (personal profile or company page), X, Instagram, Facebook Pages, Threads, TikTok, YouTube, Pinterest, Bluesky, Mastodon, Discord, Telegram, Slack and Google Business Profile**.

This plugin bundles the Antwork connector (`https://api.antwork.io/mcp`) with skills for the multi-step workflows. The connector alone handles single steps: drafting one post, scheduling, publishing, media and connecting accounts. The skills cover the work that takes several steps and some judgment.

## Get started

In claude.ai and Cowork, add Antwork from **Customize > Plugins**. In Claude Code:

```
/plugin install antwork --marketplace https://github.com/polynode-co/antwork-skills.git
```

1. Install the plugin, then connect Antwork when Claude asks (or from the plugin's **Connectors** tab). You sign in to Antwork in your browser with Google or an email link. There is no API key to create or paste.
2. Ask Claude to connect a social account. It gives you a link for each network.
3. Try `/antwork audit` to see where you stand, then `/antwork ideas` or `/antwork calendar` for what to post next.

The free plan covers 2 social accounts and 10 posts a month, with no card. Paid plans start at $19 a month ([pricing](https://antwork.io/pricing)).

## Commands

You don't have to type a command: describe what you want ("plan next week", "how did last month do?") and the `antwork` router picks the skill.

| Command | What it does |
|---|---|
| `/antwork voice [account]` | Read an account's voice from its real posts, or capture one from samples. |
| `/antwork calendar <theme>` | Plan a content calendar around what's already scheduled, then schedule the batch. |
| `/antwork repurpose <source>` | Turn one piece (a blog post, newsletter, transcript) into a native version per platform. |
| `/antwork clip <video>` | Cut one long video into captioned vertical clips on your machine, each drafted for YouTube Shorts, TikTok, Instagram Reels and Facebook. Needs a local shell (Claude Code or Cowork on your computer). |
| `/antwork campaign <goal>` | Sequence a multi-post campaign or launch week. |
| `/antwork ideas [topic]` | Hooks and angles grounded in what already performed for the account. |
| `/antwork viral <niche or @creator>` | Study what went viral in a niche or for a creator, name the patterns, and write variations in your voice. |
| `/antwork analytics [range]` | Pull performance and engagement and write a report with what to do next. |
| `/antwork audit` | A full social-presence audit with a 0–100 Social Health Score. |
| `/antwork ship` | Turn the current repo's commits, merged PRs or a release into build-in-public posts. Needs a local shell. |

Nothing is published or scheduled without your approval: every post is a draft until you say otherwise.

## The audit's agents

Where subagents are available (Claude Code, Cowork), `/antwork audit` runs five read-only agents in parallel: performance (30%), voice consistency (20%), cadence and timing (20%), content quality (20%), and platform coverage and growth (10%). In a chat, the same five dimensions run one after another. The weighted result is the Social Health Score.

## What the plugin runs and sends

The plugin is skills, five audit agents and one MCP server entry. It has no hooks, no scripts that start on their own, no bundled programs and no package installs.

- **One MCP server, `https://api.antwork.io/mcp`.** Claude signs in to it with OAuth; the plugin holds no API key or token. What goes through it is what you ask for: the text, media and times of the posts you approve, and reads of your workspaces, connected accounts, posts and their metrics. In Claude Code, each request also carries the header `X-Antwork-Install: antwork-skills`, which tells Antwork the connection came from this plugin rather than one added by hand. Antwork records it as the install source in its own product analytics and uses it for nothing else. What Antwork stores, and for how long, is in its [privacy policy](https://antwork.io/privacy).
- **Commands a skill asks Claude to run**, only where Claude has a shell. They show in your session and follow your permission settings, like any other command:
  - `/antwork ship` reads the current repo with `git log`, `git describe` and `git diff --stat`, and with `gh pr list` and `gh release view` when the GitHub CLI is installed. It writes nothing to the repo.
  - `/antwork clip` cuts and captions the video on your machine with ffmpeg and ffprobe. It transcribes with a local speech-to-text model (whisper.cpp, faster-whisper or openai-whisper) if one is installed. It offers to install a missing tool and installs nothing unless you agree. A transcriber's first run downloads its model weights, and the skill asks before a large download. Given a link instead of a file, it downloads that video with yt-dlp if you have it. The full video stays on your machine, with no cloud transcription; only the clips you approve are uploaded, to Antwork.
  - Attaching a local file to a post (a clip, a screenshot) is one HTTP PUT of that file to the one-time upload address that the connector's `add_media` tool returns, on `api.antwork.io`.
- **Nothing else.** The skills send no data to any other service.

## Help

- Documentation: [antwork.io/docs/skills](https://antwork.io/docs/skills) and [antwork.io/docs/mcp](https://antwork.io/docs/mcp)
- Support: [antwork.io/contact](https://antwork.io/contact)
- Privacy: [antwork.io/privacy](https://antwork.io/privacy) · Terms: [antwork.io/terms](https://antwork.io/terms)
- Source: [github.com/polynode-co/antwork-skills](https://github.com/polynode-co/antwork-skills)

## License

MIT
