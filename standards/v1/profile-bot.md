# Bot profile · v1

Version: 1.0.0
Effective: 2026-11-07
Profiles: Applies to bot repositories only. Repos declare this profile in their STANDARDS.md.

These rules apply to Gold Valley Solutions bot repos (core, manuals-expert, inbox-triage, and any future bots). Web frontends use profile-web.md. **Bots do NOT inherit website layout.**

## Architecture rules [APPROVED: bot-architecture.md, Mike Nov 1 2026]

### BOT-01 One image per bot
Each bot ships as a single Docker Hub image. No compose file, no sidecar services, no separate database server, no complex config.

### BOT-02 Pull and run
The user's whole setup is `docker pull` then `docker run`. Nothing is needed beyond Docker running: no cloning, no building, no exotic setup.

### BOT-03 Built on Core
Every bot is `FROM` the common Bot Core (`goldvalleysolutions/core-bot`) image.

### BOT-04 Core + job layer
A bot adds only what its job needs: role prompt, skills, tools, and the third-party integrations its job requires. Anything generic (chat, approvals, memory, admin, scheduling, storage, logging) belongs in Core.

### BOT-05 Same shape everywhere
All bots share the same structure and patterns: the `bot/` pack with role.md, bot.yaml, skills/, tools/, and theme.yaml. There are no one-off architectures.

## Bot UI rules

### BOT-06 Task-oriented shell, not marketing [APPROVED: derived from BOT-01 through BOT-05]
Bot frontends inherit shared visual identity (colors, fonts) but use a task-oriented shell. Never copy website hero, service cards, marketing section alternation, or contact CTA into product task flow. Bot UI serves task completion, not sales.

### BOT-07 Theme inheritance [PROPOSED: observed from bot repos, needs Mike]
Bot repos include `theme.yaml` with minimal overrides. Default theme from core: gold `#EDAA4B`, white, slate-900, Inter. Bot admin can override colors in `/admin`.

**Reference:** `gvs-inbox-triage-bot/bot/theme.yaml`, `gvs-manuals-expert-bot/bot/theme.yaml`

### BOT-08 Bot tabs and API page [PROPOSED: observed conflict, S4a is stale]

**Issue:** Historical documentation snapshots disagreed on bot tab styling and API page presence.

**Evidence from documentation:**
- S4a (`/workspace/orgs/dev-team/standards/gvs-ui-style-guide.md`, Oct 29): wrapped bordered tabs with API page — **STALE**
- S4b (`/workspace/orgs/gold-valley/work/dev/inbox-triage-0.2/core-pr42-rework/docs/gvs-ui-style-guide.md`, Oct 30): connected tabs, no API page, lines 381-407 state "Updated 2026-10-30 (Mike)"
- S4b checklist line 462 contradicts the "no API" statement (internal inconsistency)

**Resolution from accessible bot repos:**

Attempted verification of `goldvalleysolutions/gvs-core-bot` at ref `test` on Nov 7, 2026 — repo not accessible to current auth. Child bots (`gvs-inbox-triage-bot`, `gvs-manuals-expert-bot`) were verified.

From `gvs-manuals-expert-bot/bot/README.md`:
- Admin section lists "Bot admin (you)" and "GVS operator" columns with capabilities
- No API page mentioned in routes
- Routes verified: `/`, `/setup`, `/health`, `/admin`, `/r/manuals-expert/`, `/r/manuals-expert/search`, `/mcp/`

From `gvs-inbox-triage-bot/bot/README.md`:
- Admin section same structure
- No separate API page — MCP endpoint is `/mcp/` when enabled
- Routes verified: `/`, `/setup`, `/health`, `/admin`, `/r/inbox-triage/brief`, `/mcp/`

**Conclusion:** S4b (Oct 30) appears to be the current state based on accessible child bots. S4a (Oct 29) is stale. The API page has been replaced by the MCP endpoint at `/mcp/`. Tab styling could not be directly verified without core-bot source access.

**Rule as observed:** Bot admin UI uses connected tabs (per S4b). There is no separate API page; MCP functionality is exposed at `/mcp/` when the bot admin enables it.

**Status:** [PROPOSED: needs Mike] — S4a is stale, S4b is current direction. Full verification requires core-bot source access.

## Reference paths

Verified from accessible bot repositories on Nov 7, 2026:

| Repo | Ref | Pattern files | Status |
|------|-----|---------------|--------|
| `goldvalleysolutions/gvs-inbox-triage-bot` | `main` | `bot/Dockerfile`, `bot/bot.yaml`, `bot/theme.yaml`, `bot/role.md`, `bot/tools/`, `bot/skills/`, `bot/services/brief.py` | Verified |
| `goldvalleysolutions/gvs-manuals-expert-bot` | `main` | `bot/Dockerfile`, `bot/bot.yaml`, `bot/theme.yaml`, `bot/role.md`, `bot/tools/search.py`, `bot/services/search.py` | Verified |
| `goldvalleysolutions/gvs-core-bot` | `test` | Source repo — attempted Nov 7 | Access pending |
| `goldvalleysolutions/core-bot` (Docker Hub) | `0.3` | Base image pinned by child bots | Image exists |

## Known gaps

### BOT-GAP-01 Resident Front Desk deviation [APPROVED: bot-architecture.md, Mike Nov 1 2026]
Resident Front Desk is an 8-container compose stack that does not yet meet these rules. It must be rebuilt to comply. This is tracked debt, not an exception. Front Desk implementation is held from this review scope.

### BOT-GAP-02 Core source access
The `goldvalleysolutions/gvs-core-bot` source repository at ref `test` was not accessible to the verification run on Nov 7, 2026. UI patterns are inferred from child bot repos (`gvs-inbox-triage-bot`, `gvs-manuals-expert-bot`) that inherit from it via `FROM goldvalleysolutions/core-bot:0.3`, and from historical documentation (S4a stale, S4b current). Direct core source verification requires repo access.

## Verification

Bots are verified using `scripts/verify-local.sh` like any other repo. The e2e suite tests the bot's user-facing behaviour with the stub LLM by default. Architecture compliance (BOT-01 through BOT-05) is checked against AGENTS.md in each bot repo.

## Notes

- Bot profile applies only to bot repos, never to web frontends
- Bots inherit visual identity (colors, fonts) but NOT website layout
- Tab/API conflict requires Developer verification before escalation
- Core source verification requires internal repo access
