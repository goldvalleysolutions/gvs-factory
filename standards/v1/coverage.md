# Frontend coverage · v1

Version: 1.0.0
Effective: 2026-11-07

This document lists the active GVS frontends to check for consistency review. Profile ownership: Marketing owns style and brand rules; Dev owns architecture and code rules.

## Access notes

**Nov 7, 2026:** Attempted to verify repos via GitHub API and git clone. The following repos were NOT accessible to the current authentication:
- `goldvalleysolutions/gvs-core-bot` — referenced in bot READMEs at commits `1c6e619` (inbox-triage) and `a04a736` (manuals-expert)
- `goldvalleysolutions/www.goldvalleysolutions.com` — referenced in Marketing sources S5/S6

Verification below is based on accessible repos only. Items marked "Verified" were read from the repos. Items marked "Access pending" require access to the private repos.

---

## Bot frontends

### Core Bot (access pending)

| Field | Value | Source |
|-------|-------|--------|
| **Repo** | `goldvalleysolutions/gvs-core-bot` | Bot READMEs reference `git clone https://github.com/goldvalleysolutions/gvs-core-bot.git` |
| **Ref** | `test` | User instruction |
| **Docker Hub** | `goldvalleysolutions/core-bot:0.3` | Verified from `gvs-inbox-triage-bot/bot/Dockerfile` |
| **Profile** | `profile-bot`, `brand` | — |
| **Style owner** | Marketing | — |
| **Architecture owner** | Dev | — |
| **Status** | Access pending — repo not accessible to current auth | Attempted Nov 7, 2026 |

**Routes (inferred from child bots):**

Routes are inherited by child bots. Based on patterns observed in accessible bot repos:

| Route | Purpose | Source |
|-------|---------|--------|
| `/` | Home/chat page | Verified: `gvs-inbox-triage-bot/tests/e2e/test_inbox_triage.py` |
| `/setup` | Setup wizard | Verified: `gvs-inbox-triage-bot/tests/e2e/ui.py` |
| `/health` | Health check | Verified: `gvs-manuals-expert-bot/tests/e2e/test_manuals_expert.py` |
| `/admin` | Admin panel | Verified: `gvs-inbox-triage-bot/tests/e2e/ui.py` |
| `/admin/login` | Admin login | Verified: `gvs-inbox-triage-bot/tests/e2e/ui.py` |
| `/login` | User login | Verified: `gvs-manuals-expert-bot/bot/README.md` |
| `/mcp/` | MCP endpoint (when enabled) | Verified: `gvs-inbox-triage-bot/tests/e2e/ui.py` |
| `/r/<bot-slug>/` | Bot-specific pages | Verified: child bot implementations |

**Setup wizard steps (from `ui.py`):**
- `bot_admin` — create admin password
- `access` — who can use the bot (policy: anyone, signed_in)
- `model` — AI model selection
- `connectors` — mail/SMTP config (bot-specific)
- `wizard` — bot-specific wizard (optional)
- `self_test` — run self-test

**UI reference paths:** Access pending. Child bots inherit from core via Docker `FROM`.

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

1. **Core-bot source access:** `goldvalleysolutions/gvs-core-bot` not accessible — UI patterns inferred from child bots
2. **Website source access:** `goldvalleysolutions/www.goldvalleysolutions.com` not accessible — routes from Marketing sources unverified
3. **Website SHA pin:** Ref is mutable `test`. Pin SHA before enforcement.
4. **Role/state screenshots:** Reference screenshots per page family and role/state not captured
5. **Release records:** Bot release status needs explicit source evidence
