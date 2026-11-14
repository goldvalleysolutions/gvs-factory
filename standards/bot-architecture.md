# Gold Valley Bots: architecture and Core packaging

Standing rules for every bot. Check them on every plan, PR, and review.

## Architecture (Mike, Nov 1 2026)

1. **One image per bot.** Each bot ships as a single Docker Hub image. No compose file, no sidecar services, no separate database server, no complex config.
2. **Pull and run.** The user's whole setup is `docker pull` then `docker run`. Nothing is needed beyond Docker running: no cloning, no building, no exotic setup.
3. **Built on Core.** Every bot is `FROM` the common Bot Core (`gvs-core-bot` / `goldvalleysolutions/core-bot`) image.
4. **Core + job layer.** A bot adds only what its job needs: role prompt, skills, tools, and the third-party integrations its job requires. Anything generic (chat, approvals, memory, admin, scheduling, storage, logging) belongs in Core.
5. **Same shape everywhere.** All bots share the same structure and patterns (the `bot/` pack: `role.md`, `bot.yaml`, `skills/`, `tools/`, theme). There are no one-off architectures.

Known gap: Resident Front Desk (an 8-container compose stack) must be rebuilt to meet these rules. Record it as debt, not an exception.

## Core packaging and security

Distilled from current `gvs-core-bot` `AGENTS.md` on `test`. These supersede older Oct 17 box documents wherever they disagree.

- **Pin Core.** Pin by `X.Y` / `X.Y.Z` (and `sha-*` where GHCR is used). Never tag or build from `latest` (never `latest`). Never publish `:latest`.
- **MCP only.** MCP (`/mcp`) is the only general external interface. No general REST API and no `/openapi.json`, `/docs`, or `/redoc`. The web UI session routes and `/health` are the other allowed routes. A bot may add a signature-verified inbound webhook under `/r/<slug>/` only when that integration needs one.
- **One DB.** One SQLite DB (`/data/bot.db`) plus `/data/bot.key`. Secrets encrypted at rest. Never commit keys, tokens, passwords, or `.env` files.
- **Setup.** Unconfigured boxes open `/setup`. Keys are write-only and masked. Root/GVS operator login is GVS-only (short-lived signed token); self-hosters get box admin only.
- **Stub default.** Default configuration and CI use the stub model and stub connectors: no network and no paid provider calls.
- **Approvals.** Tools in a bot's `approval_required` list never run straight from chat.
- **Git flow.** PRs go to `test`; only Mike merges `test` into `main`. A merge to `main` is the publish switch.
- **License.** Apache 2.0 with `NOTICE`.

Bot README shape: see `standards/readme-template.md`.
