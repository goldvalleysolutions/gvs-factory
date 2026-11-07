# Frontend coverage · v1

Version: 1.0.0
Effective: 2026-11-07

This document lists the active GVS frontends to check for consistency review. Profile ownership: Marketing owns style and brand rules; Dev owns architecture and code rules.

## Access notes

**Nov 7, 2026:** Verification status:
- `goldvalleysolutions/gvs-core-bot` — **Verified** via separate read-only run at `test` ref commit `e4b0f3a`
- `goldvalleysolutions/gvs-inbox-triage-bot` — Verified via GitHub API at `main`
- `goldvalleysolutions/gvs-manuals-expert-bot` — Verified via GitHub API at `main`
- `goldvalleysolutions/www.goldvalleysolutions.com` — Access pending (not accessible to current auth)

---

## Bot frontends

### Core Bot (verified)

| Field | Value | Source |
|-------|-------|--------|
| **Repo** | `goldvalleysolutions/gvs-core-bot` | Verified via read-only run |
| **Ref** | `test` commit `e4b0f3a` | Verified Nov 7, 2026 |
| **Docker Hub** | `goldvalleysolutions/core-bot:0.3` | Verified from child bot Dockerfiles |
| **Profile** | `profile-bot`, `brand` | — |
| **Style owner** | Marketing | — |
| **Architecture owner** | Dev | — |
| **Status** | Verified Nov 7, 2026 | — |

**Routes (verified from `gvs-core-bot@e4b0f3a`):**

| Route | Purpose | Source |
|-------|---------|--------|
| `/` | Home/chat page | `core/app.py` |
| `/health` | Health check | `core/app.py` |
| `/login` | User login | `core/app.py` |
| `/logout` | User logout | `core/app.py` |
| `/chat/approvals/{aid}` | Approval handling | `core/app.py` |
| `/chat/delete` | Chat deletion | `core/app.py` |
| `/static/*` | Static assets | `core/app.py` |
| `/setup` | Setup wizard | `core/setup/routes.py` |
| `/setup/test` | Setup test endpoint | `core/setup/routes.py` |
| `/setup/models` | Model selection | `core/setup/routes.py` |
| `/admin` | Admin panel | `core/admin/*.py` |
| `/admin/mcp` | MCP admin + token routes | `core/admin/*.py` |
| `/admin/users` | User management | `core/admin/*.py` |
| `/admin/retention` | Data retention | `core/admin/*.py` |
| `/admin/settings` | Settings panel | `core/admin/*.py` |
| `/gvs/*` | GVS-only routes | `core/app.py` |
| `/mcp` | MCP endpoint (when enabled) | `core/mcp/server.py` line 140 |
| `/r/<slug>/` | Bot add-on pages | `core/sdk/service.py` |

**Admin tabs (verified from `core/admin/settings.py` `tab_button()`):**
- Bot
- Model
- Email (conditional)
- Users
- MCP (Advanced)
- Data (Advanced)

**Tab styling (verified from `core/ui/gvs.css` lines 326-363):**
- Connected strip with shared baseline
- Gold underline on active tab
- Scrolls sideways, does not wrap

**No API page (verified from `core/app.py` lines 210-214):**
- OpenAPI disabled
- `/docs` disabled
- `/redoc` disabled

**UI reference paths (verified from `gvs-core-bot@e4b0f3a`):**

| Component | Path | Purpose |
|-----------|------|---------|
| Shared CSS | `core/ui/gvs.css` | GVS styling including tabs |
| Page builder | `core/ui/html.py` `page()` | HTML page generation |
| Theme | `core/ui/theme.py` | Merges `/bot/theme.yaml` |
| Chat UI | `core/ui/chat.py` | Chat interface |
| Approvals UI | `core/ui/approvals.py` | Approval cards |
| Client JS | `core/ui/bot.js` | Client-side JavaScript |
| Fonts | `core/ui/fonts/` | Inter font files (locally served) |
| Brand assets | `core/ui/brand/` | Logo and brand assets |

---

### Inbox Triage Bot (verified)

| Field | Value | Source |
|-------|-------|--------|
| **Repo** | `goldvalleysolutions/gvs-inbox-triage-bot` | Verified via GitHub API |
| **Ref** | `main` | Verified via GitHub API |
| **Core pin** | `goldvalleysolutions/core-bot:0.3` | Verified: `bot/Dockerfile` line 9 |
| **Profile** | `profile-bot`, `brand` | — |
| **Style owner** | Marketing | — |
| **Architecture owner** | Dev | — |
| **Status** | Verified Nov 7, 2026 | — |

**Routes:**

| Route | Purpose | Source |
|-------|---------|--------|
| `/` | Home/chat page | Verified: `bot/README.md`, `tests/e2e/test_inbox_triage.py` |
| `/setup` | Setup wizard (bot_admin, access, model, connectors, self_test) | Verified: `tests/e2e/test_inbox_triage.py` line 54 |
| `/health` | Health check | Verified: `bot/README.md` |
| `/admin` | Admin panel | Verified: `tests/e2e/ui.py` |
| `/r/inbox-triage/brief` | Brief page (daily brief, Run now, Forget mailbox) | Verified: `tests/e2e/test_brief_page.py` line 14 |
| `/mcp/` | MCP endpoint (ask, search, list_items, email.send) | Verified: `bot/bot.yaml` mcp.expose |

**Reference paths:**

| Component | Path | Status |
|-----------|------|--------|
| Dockerfile | `bot/Dockerfile` | Verified |
| Bot manifest | `bot/bot.yaml` | Verified |
| Theme | `bot/theme.yaml` | Verified — inherits core GVS defaults (gold #EDAA4B, white, slate-900, Inter) |
| Role | `bot/role.md` | Verified (file exists) |
| Tools | `bot/tools/` | Verified |
| Skills | `bot/skills/` | Verified |
| Services | `bot/services/` | Verified — `brief.py` for daily_brief job |
| E2E tests | `tests/e2e/` | Verified — desktop (1280x800), mobile (390x844), stub LLM |

---

### Manuals Expert Bot (verified)

| Field | Value | Source |
|-------|-------|--------|
| **Repo** | `goldvalleysolutions/gvs-manuals-expert-bot` | Verified via GitHub API |
| **Ref** | `main` | Verified via GitHub API |
| **Core pin** | `goldvalleysolutions/core-bot:0.3` | Verified: `bot/README.md` |
| **Profile** | `profile-bot`, `brand` | — |
| **Style owner** | Marketing | — |
| **Architecture owner** | Dev | — |
| **Status** | Verified Nov 7, 2026 | — |

**Routes:**

| Route | Purpose | Source |
|-------|---------|--------|
| `/` | Home/chat page | Verified: `bot/README.md`, `tests/e2e/test_manuals_expert.py` |
| `/setup` | Setup wizard (bot_admin, access, model, self_test — no connectors) | Verified: `tests/e2e/test_manuals_expert.py` |
| `/health` | Health check (includes bot version) | Verified: `tests/e2e/test_manuals_expert.py` line 62 |
| `/admin` | Admin panel | Verified: `bot/README.md` |
| `/login` | User login | Verified: `bot/README.md` |
| `/r/manuals-expert/` | Manuals page (upload, demo-mode label) | Verified: `tests/e2e/test_manuals_expert.py` line 34 |
| `/r/manuals-expert/search` | Search endpoint (JSON, requires auth, 401 logged out) | Verified: `tests/e2e/test_manuals_expert.py` line 33 |
| `/mcp/` | MCP endpoint (ask, search, list_items, search_manuals) | Verified: `bot/bot.yaml` via README |

**Reference paths:**

| Component | Path | Status |
|-----------|------|--------|
| Dockerfile | `bot/Dockerfile` | Verified (file exists) |
| Bot manifest | `bot/bot.yaml` | Verified (file exists) |
| Theme | `bot/theme.yaml` | Verified — inherits core GVS defaults |
| Role | `bot/role.md` | Verified (file exists) |
| Tools | `bot/tools/search.py` | Verified — `search_manuals` |
| Services | `bot/services/search.py` | Verified — Manuals page + upload |
| Demo manuals | `demo/manuals/` | Verified (referenced in README) |
| E2E tests | `tests/e2e/` | Verified — desktop (1280x800), mobile (390x844), stub LLM |

---

## Website (access pending)

| Field | Value | Source |
|-------|-------|--------|
| **Repo** | `goldvalleysolutions/www.goldvalleysolutions.com` | Marketing sources S5 |
| **Ref** | `test` | Marketing sources S5 |
| **Profile** | `profile-web`, `brand`, `blog` | — |
| **Style owner** | Marketing | — |
| **Architecture owner** | Dev | — |
| **Status** | Access pending — repo not accessible to current auth | Attempted Nov 7, 2026 |

**Routes (from Marketing sources, unverified):**

| Route family | Profile | Reference | Source |
|--------------|---------|-----------|--------|
| `/` (homepage) | WEB-MARKETING | Homepage-only | S5 |
| `/services/*` | WEB-MARKETING | `base.njk` shell | S5 |
| `/portfolio/*` | WEB-MARKETING | `base.njk` shell | S5 |
| `/about` | WEB-MARKETING | `base.njk` shell | S5 |
| `/training` | WEB-MARKETING | Header/footer Let's Talk only | S7 |
| `/contact` | WEB-MARKETING | `base.njk` shell | S5 |
| `/thoughts/*` | WEB-BLOG-* | blog-classic/engineering | S3/S6 |

**Reference paths (from Marketing sources, unverified):**

| Component | Path | Source |
|-----------|------|--------|
| Base shell | `frontend/src/_includes/base.njk` | S5 |
| Blog CTA | `frontend/src/_includes/blog/cta.njk` | S9 |
| Blog diagram | `frontend/src/_includes/blog/diagram.njk` | S9 |
| Blog classic | `frontend/src/_includes/blog-classic.njk` | S6 |
| Blog engineering | `frontend/src/_includes/blog-engineering.njk` | S6 |
| Theme | `frontend/tailwind.config.js` | S5 |
| Styles | `frontend/src/css/input.css` | S6 |
| AGENTS.md | `AGENTS.md` | S5 |

---

## Excluded frontends

### Front Desk (held)

| Field | Value | Source |
|-------|-------|--------|
| **Status** | Implementation held | BOT-GAP-01 in profile-bot.md |
| **Reason** | 8-container compose stack, does not meet BOT-01 through BOT-05 | bot-architecture.md |

Excluded from consistency review until rebuilt to meet architecture rules.

---

## Unverified placeholders

| Name | Evidence | Status |
|------|----------|--------|
| Back Office Clerk | Task context mention | No verified repo/frontend |
| Weekly Brief | Task context mention | No verified repo/frontend |
| Other GVS frontends | — | Dev to identify demos, internal tools |

---

## Profile ownership

| Owner | Scope |
|-------|-------|
| **Marketing** | Style rules, brand rules, visual identity, voice, diagrams |
| **Dev** | Architecture rules, code patterns, component boundaries, tests, routes |

A rule authored by Marketing does not override Dev's architecture decisions. A rule authored by Dev does not override Marketing's brand decisions.

---

## Inventory gaps

1. **Website source access:** `goldvalleysolutions/www.goldvalleysolutions.com` not accessible — routes from Marketing sources unverified
2. **Website SHA pin:** Ref is mutable `test`. Pin SHA before enforcement.
3. **Role/state screenshots:** Reference screenshots per page family and role/state not captured
4. **Release records:** Bot release status needs explicit source evidence
