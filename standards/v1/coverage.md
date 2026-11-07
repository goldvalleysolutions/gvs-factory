# Frontend coverage · v1.0.0

Version: v1.0.0
Effective: 2026-11-07

This document lists the active GVS frontends to check for consistency review. Profile ownership: Marketing owns style and brand rules; Dev owns architecture and code rules.

## Access notes

**Nov 7, 2026:** Verification status:
- `goldvalleysolutions/gvs-core-bot` — **Verified** via separate read-only run at `test` ref commit `e4b0f3a`
- `goldvalleysolutions/gvs-inbox-triage-bot` — Verified via GitHub API at `main`
- `goldvalleysolutions/gvs-manuals-expert-bot` — Verified via GitHub API at `main`
- `goldvalleysolutions/www.goldvalleysolutions.com` — **Verified** via separate read-only run at `test` ref commit `05346b0`

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

## Website (verified)

| Field | Value | Source |
|-------|-------|--------|
| **Repo** | `goldvalleysolutions/www.goldvalleysolutions.com` | Verified via read-only run |
| **Ref** | `test` commit `05346b0` | Verified Nov 7, 2026 |
| **Profile** | `profile-web`, `brand`, `blog` | — |
| **Style owner** | Marketing | — |
| **Architecture owner** | Dev | — |
| **Status** | Verified Nov 7, 2026 | — |

**Config and data (verified from `www@05346b0`):**

| Component | Path |
|-----------|------|
| Eleventy config | `frontend/.eleventy.js` |
| Data files | `frontend/src/_data/` |
| Bots data | `frontend/src/_data/bots.json` (2 released, 3 coming soon) |
| Service pages data | `frontend/src/_data/servicePages.json` |

**Layouts (verified from `frontend/src/_includes/`):**

| Layout | Purpose |
|--------|---------|
| `base.njk` | Base shell — nav at lines 92-133, footer at lines 137-180 |
| `article.njk` | Legacy blog layout (default for older posts) |
| `blog-classic.njk` | Classic blog family (Foundations, Putting It to Work) |
| `blog-engineering.njk` | Engineering blog family (Behind the Build) |
| `service-page.njk` | Service pages (fractional-cto, ai-agents, integrations) |
| `training-page.njk` | Training page |
| `redirect.njk` | Redirect pages |

**Top-level pages (verified):**

| Page | Template/Route |
|------|----------------|
| Homepage | `index` |
| About | `about` |
| Portfolio | `portfolio` |
| Thoughts (blog index) | `thoughts` |
| FAQ | `faq` |
| 404 | `404` |
| Sitemap | `sitemap` |
| Pricing | `pricing.njk` — redirects to `/` |

**Services (verified from `services/service.njk` + `_data/servicePages.json`):**

| Service | Layout |
|---------|--------|
| `/services/fractional-cto` | `service-page.njk` |
| `/services/ai-agents` | `service-page.njk` |
| `/services/integrations` | `service-page.njk` |
| `/services/training` | `training-page.njk` |

**Bots pages (verified):**

| Page | Template |
|------|----------|
| Portfolio bots listing | `portfolio.njk` |
| Individual bot pages | `portfolio-bot.njk` |

**Projects (verified):**

| Page | Template |
|------|----------|
| Projects listing | `projects.njk` |
| Individual project pages | `portfolio-project.njk` |

**Blog posts (verified from `frontend/src/thoughts/`):**

| Template | Posts |
|----------|-------|
| `blog-classic.njk` | `gold-valley-bots`, `how-i-use-agents-to-run-my-consultancy` |
| `blog-engineering.njk` | `software-factory` |
| `article.njk` (legacy) | `ga4-mcp-server`, `fractional-cto-first-30-days`, `what-breaks-in-production`, `agent-vs-api-call` |

**Blog previews:** `frontend/src/blog/preview/`

**Partials (verified from `frontend/src/_includes/`):**

| Partial | Purpose |
|---------|---------|
| `contact-form` | Contact form |
| `contact-panel` | Contact panel |
| `contact-modal` | Contact modal |
| `cta-band` | CTA band (legacy) |
| `page-hero` | Page hero |
| `blog/cta` | Blog CTA |
| `blog/diagram` | Blog diagram |

**Tokens (verified from `frontend/tailwind.config.js` lines 6-20):**

| Token | Value | Line |
|-------|-------|------|
| `brand` (gold) | `#EDAA4B` | line 8 |
| `brand.dark` | `#9A6700` | — |

**CSS:** `frontend/src/css/input.css`

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

1. **Role/state screenshots:** Reference screenshots per page family and role/state not captured
2. **Release records:** Bot release status needs explicit source evidence

## Verification complete

All active frontends verified Nov 7, 2026:
- `gvs-core-bot@e4b0f3a` — routes, tabs, UI paths
- `gvs-inbox-triage-bot@main` — routes, reference paths
- `gvs-manuals-expert-bot@main` — routes, reference paths
- `www@05346b0` — layouts, pages, blog posts, tokens
