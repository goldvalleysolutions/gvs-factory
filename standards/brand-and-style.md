# Brand, diagrams, and site/blog standards

Settled rules for Gold Valley public and product surfaces. Consuming repos pin factory `main` once per task (see `docs/adopt.md`) and follow these files. Do not copy them into the consumer.

## Brand tokens

| Token | Value | Notes |
|---|---|---|
| Brand gold | `#EDAA4B` | Buttons, fills, borders. Logo accents `#FF914D` / `#FFBE59` are not alternate button golds. |
| Gold text on white or cream | `#9A6700` | Never use `#EDAA4B` as text on white or cream (contrast ~2.0:1). |
| Ink | `#0F172A` / `#111827` | Titles and body on light surfaces; text on gold steps. |
| White | `#FFFFFF` | Page and light fills. |
| Text on light | `#0F172A` | |
| Text on dark | `#E2E8F0` / `#CBD5E1` | |
| Muted | `#475569` | Sub text, arrows. |
| Type | Inter 300-700 | |
| Icons | Bootstrap Icons 1.11.3 | |
| Logo | https://www.goldvalleysolutions.com/assets/images/logo.png | |

**Voice:** plain, no hype, no invented numbers; approval steps visible. Public CTAs are "Send a message" / "Request a call" or the site's "Let's Talk". No phone numbers in blog or README body copy. Marketing reviews each release kit before anything goes public.

### Known gap (do not redesign in this PR)

White text on brand gold (`#EDAA4B`) is about 2.0:1 and fails WCAG AA (4.5:1 normal text, 3:1 large text). Document this as a known gap. Do not change gold button colors in factory or consuming PRs solely to close this gap. Mike will reevaluate it with Marketing after testing.

## Diagrams and infographics

**Style A** (Claude training deck / Nov 1 diagram style guide, plus Nov 10 infographic updates) is the sole standard for blog, project, website, and deck diagrams.

**Retired:** Style B swimlanes and text-only diagrams. Do not ship them as current options.

Binding rules:

- Light background; gold means the person; the person is always "You", never a name.
- Green = safe, red = risk, never decoration.
- Inter; one idea per graphic.
- Arrows slate `#475569` with small filled triangle arrowheads that stay proportional to the line, never visually dominant.
- No em or en dashes in reader-facing graphic text.
- Alt text is the path in plain sentences plus the takeaway.
- In article graphics, every text string must render at or below the article body size (`<= 16px` on goldvalleysolutions.com Thoughts posts). Verify by measuring at 1280 and 390 CSS px widths. Slide decks may still use slide-column sizes.

Distill palette and rules here; do not vendor `gvsdiagram.py`, fonts, or PNG examples into this repo.

## Settled site/blog rules

From `www.goldvalleysolutions.com` `AGENTS.md` on `test`, Mike's Nov 11 Thoughts decision, and Mike's Nov 13 confirmations:

- Blog posts have no phone numbers, contact details, or pricing. Link to `/#contact` or the relevant service or portfolio page.
- New pages and posts match the current site's layouts, tone, and components.
- Thoughts page: Series and Articles panels both sit on a white background. No dark photo band and no transparent or clear Articles band. Headings use the usual dark section style on white.
- Website tests and deploys use `?gv_internal=1`.
- Training is listed at $175/hour with a free 30-minute consultation.
- The Pricing page is retired.
- No "Professor" persona.

---

## [PROPOSED]

Unconfirmed UI and style rules. Reviewers may note them. **`[PROPOSED]` rules must not block a PR.**

Sources distilled below: historical `gvs-ui-style-guide.md` and unconfirmed candidates from Marketing canonical style input v0.2. Do not treat observed site chrome or old box screenshots as approved policy. Where a UI-guide item conflicts with settled Core packaging (for example an Admin API table fed by `/openapi.json`, or keeping `/docs`), the settled Core rule in `standards/bot-architecture.md` wins; the conflicting item stays proposed or is marked superseded.

### Proposed bot chrome (from historical UI guide)

Not blocking. Informational only until Marketing and Mike settle them.

- Sticky full-width header `bg-black/90` with backdrop blur; gold-outline CTA; full-width black footer; frosted panels on a photo background.
- Controls: `rounded-lg` (~0.5rem) for buttons and inputs; cards ~0.75rem; dialogs ~1rem. No pill inputs, pill buttons, or floating pill chrome.
- Primary gold buttons with white label (see known gap above); outline gold secondary.
- Admin as one page of tabs (Model, Email, Look, This box, Logs, API, Approvals, MCP). API is not a top-nav item.
- Sign-in password show/hide with an accessible eye toggle.
- Footer product copy "Powered by Gold Valley Solutions" linking to the public site.

### Superseded by settled Core (do not treat as current policy)

- Admin → API as an in-product table fed by `/openapi.json`, or keeping `/docs` as a general API surface. Settled Core: no general REST API and no `/openapi.json`, `/docs`, or `/redoc`.

### Proposed consistency candidates (canonical style input v0.2)

Still proposed unless promoted above. Examples: declare a frontend profile before consistency review; blog length target 600-800 words as an editorial flag rather than a blocker; feature claims (connectors, plugins, scheduling) need verified evidence before public copy; capture desktop and 390px screenshots for changed surfaces. Do not paste the full 30-rule table here.
