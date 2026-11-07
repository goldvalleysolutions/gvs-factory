# Blog standards · v1.0.0

Version: v1.0.0
Effective: 2026-11-07
Status: DRAFT — only rules tagged [APPROVED] are enforced; all others are non-blocking
Profiles: Applies to repositories with blog content. Repos declare this profile in their STANDARDS.md.

**Lens 5 (Consistency) may block only on rules marked [APPROVED]. All other rules go under Notes, not Findings.**

## Approved rules (blocking)

These rules have direct Mike decisions and are enforced by Lens 5.

### BL-01 Blog body content restrictions [APPROVED: Mike, direct, Nov 2026]
Blog article body excludes pricing, rates, packages, phone, email, and address. Contact via "Let's Talk". No stale Pricing-page CTA. The shared site footer remains and is the sole place for contact details on blog pages.

### BL-02 Diagram style in posts [APPROVED: Mike, direct, Nov 2026]
Diagrams in blog posts follow the Claude training deck Style A, which supersedes swimlane Style B and text-only formats. Source: S11 preserved user note "consolidate into one diagram using the Slide standards that marketing has."

## Candidate rules (non-blocking, under review)

These rules are derived from Marketing input but lack direct Mike approval. Violations go under Notes, not Findings.

### BL-03 Classic family templates [PROPOSED: reported from S3/S6, needs Mike]
Foundations and Putting It to Work series use the classic blog family (`blog-classic.njk`). Applied posts add "Concepts used" chip links. Desktop shows contents beside article; 390px readable one-column with usable contents control.

### BL-04 Engineering family templates [PROPOSED: reported from S3/S6, needs Mike]
Behind the Build series uses the engineering family (`blog-engineering.njk`) with badge, factual metadata, jump navigation, and light reading panel on ink surround. Facts hide absent values; repo button only for verified public/open-source destination.

### BL-05 Shared article components [PROPOSED: observed from S9, needs Mike]
New posts should use blog-classic or blog-engineering templates, `blog/cta.njk`, `blog/diagram.njk`, and `.blog-back` class. S9 identifies these as intended components.

### BL-06 Plain headings [PROPOSED: reported from S1/S11, needs Mike]
Plain descriptive headings, no numbered scaffolding or redundant series line. Compare title, H2s, jump links and metadata.

### BL-07 Blog length [PROPOSED: editorial target from S1, needs Mike]
600 to 800 words is an editorial target. S11 records accepted edits exceeding this. Treat as guidance, not a universal blocker. Flag outside range for review rather than silently truncating.

## Legacy layout debt

S9 reports four legacy posts on `article.njk`:
- `thoughts/agent-vs-api-call`
- `thoughts/fractional-cto-first-30-days`
- `thoughts/ga4-mcp-server`
- `thoughts/what-breaks-in-production`

These are documentation debt, not approved patterns. Current code is not automatic standard. Baseline entries below prevent new drift but are not permanent waivers.

## Debt and baseline entries

A baseline entry prevents new drift but is not a permanent waiver. Each needs an owner, target, and plan.

| Owner | Paths | Rule | Reason | Target | Approval |
|-------|-------|------|--------|--------|----------|
| Dev | thoughts/agent-vs-api-call | BL-05 | Legacy article.njk | To be migrated | Baselined 2026-11-07 |
| Dev | thoughts/fractional-cto-first-30-days | BL-05 | Legacy article.njk | To be migrated | Baselined 2026-11-07 |
| Dev | thoughts/ga4-mcp-server | BL-05 | Legacy article.njk | To be migrated | Baselined 2026-11-07 |
| Dev | thoughts/what-breaks-in-production | BL-05 | Legacy article.njk | To be migrated | Baselined 2026-11-07 |

## Notes

- This file is DRAFT as of v1.0.0 — only [APPROVED] rules are enforced
- All other rules are advisory and go under Notes
- Changing any [APPROVED] rule requires Mike's explicit approval
- Legacy layouts are debt, not approved exceptions
- The four baselined paths prevent new drift; they do not waive migration
