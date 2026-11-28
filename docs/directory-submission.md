# Claude Directory: the Antwork plugin bundle

The answers for the **Plugin bundle** form at [claude.ai/directory/manage](https://claude.ai/directory/manage),
ready to paste. Requirements read on 2026-11-28 from
[Submit your plugin](https://claude.com/docs/plugins/submit.md), the
[pre-submission checklist](https://claude.com/docs/plugins/pre-submission-checklist.md) and
[Publish to the directory](https://claude.com/docs/directory/publish.md).

Iker submits it from his Claude account. Nothing here is submitted.

## Where things stand (2026-11-28)

- **MCP connector:** submitted. The portal lists "Antwork, MCP connector, api.antwork.io, In review,
  updated Nov 19".
- **Plugin bundle:** not submitted. It is not in the portal's Submissions list, and a Directory search for
  "antwork" finds only the custom connectors on Iker's own account.
- The docs ask for both: the server as a connector, then the bundle whose skills teach Claude to use it.
  Both point at the same URL, `https://api.antwork.io/mcp`, so people who have both see one set of tools.
  Once both are submitted from the same organization, the two listings can be paired.

## 1. Kind

**Submit new** → **Plugin bundle**.

## 2. Source

| Field | Value |
|---|---|
| Repository | `polynode-co/antwork-skills` |
| Plugin path | leave empty (the plugin is at the repository root) |
| Branch or tag | leave empty (follows `main`) |

Then **Validate**. Locally, `claude plugin validate . --profile directory` finds nothing to report. The
portal also checks things the local command can't, such as whether the name is free, so it can still
report something new. If it says **Name is taken** or **Name matches a known brand**, stop and tell me.

The repo also holds `.claude-plugin/marketplace.json`, the self-hosted marketplace behind
`/plugin marketplace add https://github.com/polynode-co/antwork-skills.git`. The portal treats this folder as the one plugin, so
the marketplace file does no harm.

## 3. Listing details

There is nothing to type here: the portal reads the listing from `.claude-plugin/plugin.json` and the
README. To change something, edit those files, push and validate again. This is what it will show:

| Field | Value (from `plugin.json`) |
|---|---|
| Name | `antwork` |
| Display name | Antwork |
| Description | Plan, draft, schedule and publish across 14 networks from chat: Instagram, TikTok, LinkedIn, YouTube, X, Facebook, Threads, Pinterest, Bluesky, Mastodon, Discord, Telegram, Slack and Google Business Profile. Free plan, OAuth sign-in, no API key. Adds skills for content calendars, repurposing one piece across platforms, cutting a long video into captioned Shorts, campaigns, post ideas, variations on what went viral, build-in-public posts from your commits, brand voice, analytics and audits, plus 5 audit agents. |
| Version | 1.6.2 |
| Author | Polynode Technologies, S.L. (https://polynode.co) |
| Icon | `.claude-plugin/icon.png` (512×512 PNG), the file the Directory takes the listing icon from on the first submission; `plugin.json`'s `icon` points at the same image in `./assets/icon.png` |
| Homepage | https://antwork.io |
| Documentation | https://antwork.io/docs/skills |
| Support | https://antwork.io/contact |
| Privacy policy | https://antwork.io/privacy |
| Terms of service | https://antwork.io/terms |
| License | MIT (`LICENSE` and `"license": "MIT"`) |
| Long description | `README.md` |

The author is the company, Polynode Technologies, S.L., as on the Meerko bundle (Iker's call,
2026-11-28).

## 4. Data handling

| Question | Answer |
|---|---|
| Does the plugin read or store personal data? | **Reads, through its connector; stores none itself.** It works only through the Antwork connector (`https://api.antwork.io/mcp`): your workspaces, connected social accounts, posts, media and their metrics. The plugin's files store nothing. Antwork stores the posts, media and account connections, as its [privacy policy](https://antwork.io/privacy) describes. |
| Does it send data to services other than its declared connectors? | **No.** Everything goes to `api.antwork.io`, including file uploads (a one-time upload address that `add_media` returns). Two skills fetch, and neither sends any of your data out: `/antwork clip` downloads a video with `yt-dlp` only when you give it a link, and a local transcriber downloads its model weights on first run, after asking. Transcription runs on your machine. |
| How long does it keep data? | **The plugin keeps nothing.** `/antwork clip` writes its working files (clips, captions) to `./antwork-clips/` on your machine, and you delete them. Antwork keeps account data while the account exists. After you delete the account, it deletes your data within 30 days, and backups clear within 14 weeks ([privacy policy](https://antwork.io/privacy), section 8). |
| Is it intended for people under 18? | **No.** |

## 5. Compliance

- **Contact email:** iker.gonzalez@antwork.io (the support address in `llms-install.md` and the privacy
  policy). The portal pre-fills the address of the signed-in account. If that one differs, change it to
  one where Anthropic can reach you about Antwork.
- **The four acknowledgements:** yours to read and tick.

## 6. Review and submit

- **How new versions reach the directory:** keep **GitHub push webhook**, the default. You are a repo
  admin, so **Set up push updates** works on the confirmation page.
- **Auto-publish passing versions:** my suggestion is off until the first version is live and you have
  seen it in claude.ai. Then turn it on, so a version that passes every check goes out without a click.
- **Submit for review.**

The directory then scans each commit on `main`. Raise `version` in `plugin.json` with every release (the
Cursor manifests carry the same number). Without a new version, people who already have the plugin don't
get the update.

## After it is listed

1. **Pair it with the connector.** The bundle and the connector come from the same organization and use
   the same URL, so the portal offers to pair the two listings. Pair them.
2. **Check each surface.** In claude.ai (Customize > Plugins), the skills load and the server shows on the
   plugin's **Connectors** tab. Agents are ignored in chat, so `/antwork audit` runs its five dimensions
   one after another. Cowork and Claude Code load everything.
3. **README:** change the claude.ai install line from "not listed there yet" to the Directory listing link.

## Not asked for

The plugin bundle form has no screenshot, category or one-line-description fields, according to the
docs. The listing comes from `plugin.json` and the README. If the live form does ask for any of these:

- **One-liner (≤200 characters):** Draft, schedule and publish to 14 social networks from Claude, in each
  account's own voice, with workflows for calendars, campaigns, repurposing, Shorts, analytics and audits.
- **Categories:** Marketing, Productivity (or the nearest the form offers). The docs list no categories
  for plugins; the self-hosted marketplace uses `integration`.
- **Screenshots:** none exist for the plugin yet. Use the connector's, if it has any.

## What the docs leave open

- **The fixed `X-Antwork-Install` header in `.mcp.json`.** The checklist blocks only a *credential* in MCP
  headers ("Secret in MCP headers"). `antwork-skills` is not one, and the local directory checks pass.
  The docs don't say whether claude.ai and Cowork send a bundle's fixed headers, or whether a header
  affects pairing. Pairing is described by URL alone, and ours matches the connector exactly. If the
  portal's surface list or a reviewer objects, drop the header. Don't move it to a `?via=` query instead:
  OAuth clients compare the server URL to the protected-resource metadata (`resource:
  https://api.antwork.io/mcp`), so a query string breaks sign-in and the URL would no longer match the
  connector.
- **The root `CLAUDE.md`.** These are contributor instructions for this repo, and they ship in the plugin
  folder. `claude plugin validate` warns that Claude Code won't load them as plugin context. That is
  harmless, and the directory checks don't flag it.
