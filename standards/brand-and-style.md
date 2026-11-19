# Brand, diagrams, and site/blog standards

Settled rules for Gold Valley public and product surfaces. Consuming repos pin factory `main` once per task (see `docs/adopt.md`) and follow these files. Do not copy them into the consumer.

## Brand tokens

| Token | Value | Notes |
|---|---|---|
| Brand gold | `#EDAA4B` | The one gold for icons and every gold accent: buttons, fills, borders, rules, bullets, highlights. Use it through a single token (see "One brand gold" below). Logo accents `#FF914D` / `#FFBE59` are not alternate golds. |
| Gold text on white or cream | `#9A6700` | Text only. Never use `#EDAA4B` as text on white or cream (contrast ~2.0:1). Never use `#9A6700` for icons or accents. |
| Ink | `#0F172A` / `#111827` | Titles and body on light surfaces; text on gold steps. |
| White | `#FFFFFF` | Page and light fills. |
| Text on light | `#0F172A` | |
| Text on dark | `#E2E8F0` / `#CBD5E1` | |
| Muted | `#475569` | Sub text, arrows. |
| Type | Inter 300-700 | |
| Icons | Bootstrap Icons 1.11.3 | |
| Logo | https://www.goldvalleysolutions.com/assets/images/logo.png | |

### One brand gold

Consistency is the point of this guide. Gold must look the same everywhere.

- **Icons and gold accents use `#EDAA4B`, and only `#EDAA4B`.** This covers icons, buttons, fills, borders, rules, bullets, carousel dots, highlights and diagram fills. Don't use mustard, amber, yellow or any other gold.
- **Use it through one token, never a pasted hex.** On the website that's the `--gvs-gold-rgb` CSS variable, which Tailwind's `brand` color reads (`text-brand`, `bg-brand`, `border-brand`). Bots and other surfaces define one equivalent token.
- **Tints: one fill 10%, one border 40%; anything else is an exception.** Tints are the brand token with opacity (`bg-brand/10`, `border-brand/40`), never a new hex. Logged exception: E6 (series tiles, 8% fill). E3 and E4 (the What You Need and What Not to Paste boxes) were retired on 2026-11-19; those boxes now use the standard 10% fill and 40% border. The www test `frontend/tests/brand-gold.test.js` fails on any other brand opacity.
- **Gold text on white or cream** uses the gold-text token (`#9A6700`), and only for text.
- **Logo colors** (`#FF914D`, `#FFBE59`) stay inside the logo.
- **Enforce it with a test where you can.** The website's `frontend/tests/brand-gold.test.js` fails on any gold or yellow hex, raw `rgb(237, 170, 75)` or Tailwind `amber`/`yellow`/`orange` utility that isn't the token or a logged exception.
- **Every deviation is an exception.** It needs Mike's approval first and an entry in the Exceptions log below.

### Deviations: ask Mike first

This applies to gold and to every other rule in this file. Anyone (person or agent) who wants to deviate from a rule here must ask Mike first, and must not ship the deviation until he approves. After approval, add the exception to the Exceptions log. An exception that isn't in the log isn't approved. An entry marked `[PROPOSED]` is a known deviation that Mike hasn't approved yet. Keep it as is or fix it, but don't spread it to new places.

### Exceptions log

Every approved exception, with what it is, where it's used, why, who approved it and when. `[PROPOSED]` means Mike hasn't approved it yet.

| # | Exception | Where used | Why | Approved by | Date |
|---|---|---|---|---|---|
| E1 | Gold text `#9A6700` on white or cream (instead of `#EDAA4B`) | Website text links, kickers, post dates, series TOC titles (`text-brand-dark`); small gold labels in article graphics | `#EDAA4B` text on white is about 2.0:1 and unreadable | Mike (settled Brand tokens table) | Before 2026-11-16 |
| E2 | White label on brand-gold buttons (known contrast gap, about 2.0:1) | Primary gold buttons, site and bots | Brand look; Mike will reevaluate with Marketing after testing | Mike (Known gap section) | Before 2026-11-16 |
| E3 | Resolved: the "What You Need" box uses the standard tint (10% fill, 1px 40% border). Was: 20% fill with a 2px solid brand border (www PR #88) | Was: Claude: Putting It to Work how-tos (`.blog-needs`) | Mike chose the standard pattern after a side-by-side comparison | Resolved by Mike 2026-11-19 (chose the standard pattern) | 2026-11-19 |
| E4 | Resolved: the standing "What Not to Paste, What You Still Approve" box uses the standard tint (10% fill, 1px 40% border), same as the What You Need box. Was: the E3 20% fill / 2px border (www PR #88) | Was: Claude: Putting It to Work Articles 3-9 (`.blog-standing-box`) | Mike chose the standard pattern after a side-by-side comparison | Resolved by Mike 2026-11-19 (chose the standard pattern) | 2026-11-19 |
| E5 | Standard gold `#EDAA4B` as small text on white for series and article card dates (instead of E1) | Thoughts and Home series/article tiles | Mike: "gold tile dates - make them the standard gold"; matches the tile icon gold | Approved by Mike 2026-11-16 (standard gold `#EDAA4B`; first set in his commit `1687622` on www `test`) | 2026-11-16 |
| E6 | Series tile tint: brand token at 8% fill, 40% border | Thoughts and Home series tiles | Softer series cards | Mike (commit `1687622`) | 2026-11-16 |
| E7 | Resolved: replaced by the Tints rule above (one fill 10%, one border 40%). The other strengths (fills 20%, 30%; borders 30%, 55%, 60%) were consolidated to 10% / 40% in www PR #83. The gold `<mark>` highlight (30%) was removed earlier (www PR #80) | Was: Home and project tech stack chips, project details, series TOC current item, hosting card | Mike: consolidate to one fill and one border | Resolved by Mike 2026-11-16 (consolidated) | 2026-11-16 |
| E8 | Logo accents `#FF914D` / `#FFBE59` | Logo image only | Logo artwork | Mike (settled Brand tokens table) | Before 2026-11-16 |
| E9 | Resolved, not an exception: connector hairlines and arrowheads use standard gold `#EDAA4B`. The deeper gold `#D99A3A` is retired | Was: O2-style connectors in website diagrams (`1-chatbot.svg`, `4-ga4-mcp-dark.svg`, software factory diagram, D2 flow themes) and Claude: Putting It to Work and Agent Foundations diagram PNGs. All switched to `#EDAA4B` in www PR #80 | Mike: "For arrows, also go with standard gold" | Rejected by Mike 2026-11-16 (use standard gold) | 2026-11-16 |
| E10 | Rejected and resolved: bullet markers inside the yellow boxes use brand gold `#EDAA4B` (was `#9A6700`) | `.blog-needs` list markers, including the standing box (www PR #83) | Mike chose the standard gold | Rejected by Mike 2026-11-16 | 2026-11-16 |
| E11 | Resolved: the "You" person fill is the brand token at 10% (was cream `#FDF7ED`, which looks the same) | `frontend/diagrams/gvs-theme-light.d2` (flat `#EDAA4B1A` gradient, since D2 only takes hex), `1-chatbot.svg` (`fill-opacity` 0.1), www PR #83 | Use the token, not a new hex | Resolved by Mike 2026-11-16 | 2026-11-16 |
| E12 | Resolved as compliant: form success message keeps `#EDAA4B` text, now on a 10% fill with a 40% border | Website contact form success state (`.form-status.success`), www PR #83 | The form sits on a dark photo, so the gold text is readable; E1 applies only on white or cream | Resolved by Mike 2026-11-16 (compliant) | 2026-11-16 |
| E13 | Standard gold `#EDAA4B` as body text for one called-out sentence, no background (instead of E1) | Agent Foundations 3, "That is work we can do when a ready-made connector is not available." (`<span class="text-brand">`); replaced the gold `<mark>` highlight | Mike: "use the gold color for the text itself" | Approved by Mike 2026-11-16 | 2026-11-16 |
| E14 | Resolved as compliant: cream `#FFFBF3` in the diagram style guide and the box diagram tool is now the brand token at 10% (`#EDAA4B1A` / `LANE`) | Vault and box copies of `2026-11-01 GVS diagram style guide`, `gvsdiagram.py` (`LANE` / `CREAM`) | Use the token, not a new cream hex | Resolved by Mike 2026-11-16 (compliant) | 2026-11-16 |

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
- Connectors (hairlines and arrowheads) use brand gold `#EDAA4B` (Mike, 2026-11-16), about 1.25px at the article display width, with small filled triangle arrowheads that stay proportional to the line, never visually dominant. Connector labels stay slate `#475569`.
- No em or en dashes in reader-facing graphic text.
- Alt text is the path in plain sentences plus the takeaway.
- In article graphics, every text string must render at or below the article body size (`<= 16px` on goldvalleysolutions.com Thoughts posts). Verify by measuring at 1280 and 390 CSS px widths. Slide decks may still use slide-column sizes.

Distill palette and rules here; do not vendor `gvsdiagram.py`, fonts, or PNG examples into this repo.

## Settled site/blog rules

From `www.goldvalleysolutions.com` `AGENTS.md` on `test`, Mike's Nov 11 Thoughts decision, and Mike's Nov 13 confirmations:

- Blog posts have no phone numbers, contact details, or pricing. Link to `/#contact` or the relevant service or portfolio page.
- Articles never end with a "Next in..." or "Next up..." paragraph, or an equivalent "the next article is..." closer. Series navigation (previous/next) handles moving to the next article.
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
