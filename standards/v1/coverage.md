# Frontend coverage · v1

Version: 1.0.0
Effective: 2026-11-07

This document lists the active GVS frontends to check for consistency review. Each entry needs verification before enforcement. Profile ownership: Marketing owns style and brand rules; Dev owns architecture and code rules.

## Active frontends

### Website (to be verified)

| Field | Value | Source |
|-------|-------|--------|
| **Repo** | `goldvalleysolutions/www.goldvalleysolutions.com` | S5 |
| **Ref** | `test` (pin SHA before enforcement) | S5 |
| **Profile** | `profile-web`, `brand`, `blog` | — |
| **Style owner** | Marketing | — |
| **Architecture owner** | Dev | — |
| **Status** | To be verified | — |

**Routes:**

| Route family | Profile | Reference path | Status |
|--------------|---------|----------------|--------|
| `/` (homepage) | WEB-MARKETING | Homepage-only, not universal | To be verified |
| `/services/*` | WEB-MARKETING | `base.njk` shell | To be verified |
| `/portfolio/*` | WEB-MARKETING | `base.njk` shell | To be verified |
| `/about` | WEB-MARKETING | `base.njk` shell | To be verified |
| `/training` | WEB-MARKETING | Header/footer Let's Talk only | To be verified |
| `/contact` | WEB-MARKETING | `base.njk` shell | To be verified |
| `/thoughts/*` (blog) | WEB-BLOG-CLASSIC or WEB-BLOG-ENGINEERING | See blog families below | To be verified |

**Blog family references:**

| Series | Template | Reference | Status |
|--------|----------|-----------|--------|
| Foundations | `blog-classic.njk` | `frontend/src/_includes/blog-classic.njk` | To be verified |
| Putting It to Work | `blog-classic.njk` | `frontend/src/_includes/blog-classic.njk` | To be verified |
| Behind the Build | `blog-engineering.njk` | `frontend/src/_includes/blog-engineering.njk` | To be verified |

**Shared components:**

| Component | Path | Status |
|-----------|------|--------|
| Base shell | `frontend/src/_includes/base.njk` | To be verified |
| Blog CTA | `frontend/src/_includes/blog/cta.njk` | To be verified |
| Blog diagram | `frontend/src/_includes/blog/diagram.njk` | To be verified |
| Theme | `frontend/tailwind.config.js` | To be verified |
| Styles | `frontend/src/css/input.css` | To be verified |

---

### Inbox Triage Bot (to be verified)

| Field | Value | Source |
|-------|-------|--------|
| **Repo** | `goldvalleysolutions/gvs-inbox-triage-bot` | GitHub API read |
| **Ref** | `main` | GitHub API read |
| **Profile** | `profile-bot`, `brand` | — |
| **Style owner** | Marketing | — |
| **Architecture owner** | Dev | — |
| **Status** | To be verified | — |

**Reference paths:**

| Component | Path | Status |
|-----------|------|--------|
| Dockerfile | `bot/Dockerfile` | Verified read Nov 7 |
| Bot config | `bot/bot.yaml` | Verified read Nov 7 |
| Theme | `bot/theme.yaml` | Verified read Nov 7 |
| Role prompt | `bot/role.md` | To be verified |
| AGENTS.md | `AGENTS.md` | Verified read Nov 7 |

**Routes:** UI routes inherited from `goldvalleysolutions/core-bot:0.3`. Route inventory requires core source access.

---

### Manuals Expert Bot (to be verified)

| Field | Value | Source |
|-------|-------|--------|
| **Repo** | `goldvalleysolutions/gvs-manuals-expert-bot` | GitHub API read |
| **Ref** | `main` | GitHub API read |
| **Profile** | `profile-bot`, `brand` | — |
| **Style owner** | Marketing | — |
| **Architecture owner** | Dev | — |
| **Status** | To be verified | — |

**Reference paths:**

| Component | Path | Status |
|-----------|------|--------|
| Dockerfile | `bot/Dockerfile` | To be verified |
| Bot config | `bot/bot.yaml` | To be verified |
| Theme | `bot/theme.yaml` | Verified read Nov 7 |
| Role prompt | `bot/role.md` | To be verified |
| AGENTS.md | `AGENTS.md` | To be verified |

**Routes:** UI routes inherited from `goldvalleysolutions/core-bot`. Route inventory requires core source access.

---

### Core Bot (access pending)

| Field | Value | Source |
|-------|-------|--------|
| **Repo** | `goldvalleysolutions/core-bot` (Docker Hub) | Bot Dockerfiles |
| **Ref** | `0.3` (current pinned version) | `bot/bot.yaml` in child repos |
| **Profile** | `profile-bot`, `brand` | — |
| **Style owner** | Marketing | — |
| **Architecture owner** | Dev | — |
| **Status** | Source repo not publicly accessible | — |

**Notes:** Core-bot provides the shared UI shell, authentication, admin, and chat patterns. Bot repos inherit from it via `FROM goldvalleysolutions/core-bot:0.3`. Source repository access required for route and component inventory.

---

## Excluded frontends

### Front Desk (held)

| Field | Value | Source |
|-------|-------|--------|
| **Status** | Implementation held | BOT-GAP-01 |
| **Reason** | 8-container compose stack, does not meet bot architecture rules | bot-architecture.md |

Front Desk must be rebuilt to comply with BOT-01 through BOT-05 before consistency review applies. Excluded from this coverage scope.

---

## Unverified placeholders

These product names appear in Marketing input but lack verified frontend existence:

| Name | Evidence | Status |
|------|----------|--------|
| Back Office Clerk | Task context mention | No verified repo/frontend |
| Weekly Brief | Task context mention | No verified repo/frontend |
| Other GVS frontends | — | Dev to identify demos, internal tools |

**Rule:** Product names do not establish that a frontend exists or is released. No product UI checks until Dev supplies evidence.

---

## Inventory gaps

1. **Complete frontend inventory:** Organization-wide inventory is incomplete. Dev must confirm all active frontends.
2. **Website SHA pin:** Website ref is mutable `test`. Pin SHA before enforcement.
3. **Core-bot source:** Source repository not publicly accessible. UI patterns inferred from child repos and historical docs.
4. **Bot route inventory:** UI routes inherited from core-bot. Requires core source access.
5. **Role/state screenshots:** Matched reference screenshots per page family and role/state not yet captured.
6. **Release records:** Bot release status needs explicit source evidence.

---

## Profile ownership summary

| Owner | Scope |
|-------|-------|
| Marketing | Style rules, brand rules, visual identity, voice, diagrams |
| Dev | Architecture rules, code patterns, component boundaries, tests, routes |

A rule authored by Marketing does not override Dev's architecture decisions. A rule authored by Dev does not override Marketing's brand decisions.
