# Standards changelog

All notable changes to the versioned standards are documented in this file.

## [v1.0.0] - 2026-11-07

### Added

- `common.md` — rules that apply to all repos (CM-01 through CM-17)
  - Code patterns: no secrets, docs updated, one change per PR, local verification, evidence over self-report, three-round cap, human owns main, always-flagged items
  - Testing: Playwright e2e, new behaviour needs tests, no network/paid calls in tests
  - Process: testable acceptance criteria, scope held, flags named
  - Review: five independent lenses, consistency lens blocking, pre-panel factory guards [PROPOSED]

- `profile-bot.md` — rules for bot repositories (BOT-01 through BOT-08)
  - Architecture: one image per bot, pull and run, built on Core, Core + job layer, same shape everywhere [APPROVED: docs/bot-architecture.md, Mike Nov 1 2026]
  - UI: task-oriented shell not marketing layout, theme inheritance [PROPOSED]
  - Conflict documented: BOT-08 tab/API guidance awaiting Developer verification
  - Known gaps: Front Desk deviation, core source access
  - **Bots do NOT inherit website layout**

- `profile-web.md` — rules for web frontend repositories (WEB-01 through WEB-11)
  - [APPROVED]: rulebook location (WEB-01), five lenses (WEB-02)
  - [PROPOSED]: base template, reference files, components, Tailwind, tokens, breakpoints, panels, tests, visual regression
  - Website families: WEB-MARKETING, WEB-BLOG-CLASSIC, WEB-BLOG-ENGINEERING, HOMEPAGE, TRAINING
  - **Web profile does NOT apply to bots**

- `brand.md` — DRAFT (only [APPROVED] rules enforced)
  - [APPROVED]: Let's Talk placement (BR-01), contact scope (BR-02), pricing/rates (BR-03), diagram style (BR-04)
  - [PROPOSED]: no Professor (BR-05), dash characters (BR-06, internal constraint not enforced), palette (BR-07), fonts (BR-08), voice (BR-09), unreleased bots (BR-10)
  - Open policy gap: GAP-01 gold/white contrast awaiting Mike
  - Documentation debt: stale guides superseded

- `blog.md` — DRAFT (only [APPROVED] rules enforced)
  - [APPROVED]: body content restrictions (BL-01), diagram style (BL-02)
  - [PROPOSED]: classic family (BL-03), engineering family (BL-04), shared components (BL-05), plain headings (BL-06), blog length (BL-07)
  - Legacy layout debt: 4 posts on article.njk baselined with owner and target

- `coverage.md` — frontend inventory
  - Website: repo, ref, routes, families, components (all to be verified)
  - Inbox Triage Bot: repo, ref, reference paths
  - Manuals Expert Bot: repo, ref, reference paths
  - Core Bot: Docker Hub image, source access pending
  - Front Desk: excluded (implementation held)
  - Unverified placeholders listed
  - Inventory gaps documented
  - Profile ownership: Marketing owns style/brand, Dev owns architecture/code

### Rule IDs

Standards use stable IDs by prefix:
- CM-* — Common rules (all repos)
- BOT-* — Bot profile rules
- WEB-* — Web profile rules
- BR-* — Brand rules
- BL-* — Blog rules
- GAP-* — Open policy gaps

### Labels

- `[APPROVED: source]` — Enforced by Lens 5. Source cited.
- `[PROPOSED: reason]` — Non-blocking. Goes under Notes, not Findings.
- `[CONFLICT: description]` — Sources disagree. Requires verification or Mike decision.

### Key principles

1. Lens 5 may block only on rules marked [APPROVED]
2. Never auto-convert an observed pattern into an approved rule
3. Debt baselines prevent new drift but are not permanent waivers
4. Each baseline entry needs a target and an owner
5. Bots do NOT inherit website layout
6. Only open policy gap for Mike: gold/white contrast
