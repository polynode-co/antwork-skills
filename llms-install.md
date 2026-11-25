# Installing the Antwork MCP server (for AI agents such as Cline)

Antwork is a **hosted, remote** MCP server. There is nothing to clone, build or run locally,
no package to install and **no API key**: the user signs in through their browser (OAuth 2.1
with dynamic client registration).

## 1. Add the server

Add this entry to the MCP settings file (in Cline: `cline_mcp_settings.json`, opened with
MCP Servers → Configure MCP Servers). Keep any servers already there.

```json
{
  "mcpServers": {
    "antwork": {
      "type": "streamableHttp",
      "url": "https://api.antwork.io/mcp",
      "disabled": false
    }
  }
}
```

- The `type` must be `streamableHttp`. Without it Cline assumes the legacy SSE transport, which this server does not speak.
- Do **not** add an `Authorization` header or ask the user for a token. There is no token to paste.

## 2. Sign in

The server answers `401` until the user signs in; that is expected, not a failure. Cline then
opens the browser for authorization (or the user clicks the server's authorize action in the
MCP Servers panel). The user signs in to Antwork with Google or an email link (an account is
created on first sign-in, free plan, no card) and approves the consent screen. Tools appear
once that finishes.

## 3. Check it works

Call `list_workspaces`. It returns the user's workspaces and their connected social accounts.

If no social account is connected (a result then carries `workspaceSetup.hasSocialAccounts: false`), nothing can publish yet: call
`get_connection_urls` and give the user the link for the network they want (LinkedIn, X,
Instagram, Threads, Facebook, YouTube, TikTok, Pinterest, Bluesky, Mastodon, Discord,
Telegram, Slack or Google Business Profile).

## 4. Use it

The server's own instructions explain the drafting flow. In short: `get_post_context` for the
account, then `create_post` (a draft, nothing is published), then `schedule_post` or
`publish_post` only after the user approves that post.

## Optional: the skills

This repository also holds multi-step workflow skills (content calendar, repurposing,
campaigns, analytics, audit, and `/antwork ship`, which turns the current repo's commits into
build-in-public posts). They are optional. Install them with:

```sh
npx skills add polynode-co/antwork-skills
```

## Help

- Docs: https://antwork.io/docs/mcp
- Support: iker.gonzalez@antwork.io
