# Brand standards · v1

Version: 1.0.0
Effective: 2026-11-07
Status: DRAFT — NOT ENFORCED
Profiles: Applies to repositories with user-facing visual interfaces. Repos declare this profile in their STANDARDS.md.

**This document is a draft framework. Lens 5 (Consistency) may block only on rules marked [APPROVED]. All other rules are non-blocking and go under Notes, not Findings.**

## Approved rules (blocking)

These rules have direct Mike decisions and are enforced by Lens 5.

### BR-01 Let's Talk placement [APPROVED: Mike, direct, Nov 2026]
"Let's Talk" appears in the header and the footer on every page, including Training. Do not replace task actions (Save, Send) in bot UIs with contact CTAs.

### BR-02 Contact scope [APPROVED: Mike, direct, Nov 2026]
Contact details (phone, email, address) are allowed in the footer. Blog article body excludes contact details and pricing. The shared site footer remains and is the sole place for contact details on blog pages.

### BR-03 Pricing and rates [APPROVED: Mike, direct, Nov 2026]
Training is $175/hour with a free 30-minute consultation. The Pricing page is retired. Do not link to a Pricing page or include pricing in blog content.

### BR-04 Diagram style [APPROVED: Mike, direct, Nov 2026]
The diagram style follows the Claude training deck (Style A), which supersedes the text-only and swimlane (Style B) styles. One diagram per idea; gold = person; person labelled "You", never a name.

### BR-05 No Professor persona [APPROVED: Mike, Oct 8 2026 via S10]
No Professor persona or title in any GVS material. Source: preserved user wording "BTW - keep the professor title out of any of our stuff."

## Candidate rules (non-blocking, under review)

These rules are derived from Marketing input but lack direct Mike approval. Violations go under Notes, not Findings. They require Mike's decision before enforcement.

### BR-06 Dash characters [PROPOSED: internal working constraint, not enforced]
No U+2013 (en dash) or U+2014 (em dash) in reader-facing text. Preserve spaced hyphens. This is an internal editorial constraint for drafting (evidence class W/P from v0.2). Direct adoption provenance was not verified. Not a Mike-approved standard and not enforced.

### BR-07 Brand palette [PROPOSED: observed from S5/S6, needs Mike]
Gold `#EDAA4B`, brand-dark `#9A6700`, ink `#0F172A`, ink-800 `#111827`, white `#FFFFFF`, muted `#475569`, on-dark `#E2E8F0`, on-dark-muted `#CBD5E1`. Logo accents `#FF914D`/`#FFBE59` are not alternate button golds. (Source: observed in tailwind.config.js and input.css)

### BR-08 Inter font family [PROPOSED: observed from S5, needs Mike]
Fonts use Inter. Website loads via Google Fonts; bot products require locally served InterVariable. Delivery method is profile-specific.

### BR-09 Voice and tone [PROPOSED: agent-authored guide S1, needs Mike]
Marketing copy is plain, measured, collaborative, with concrete outcomes. No invented clients, results, or quotes. Each factual outcome has a cited source.

### BR-10 Unreleased bots [PROPOSED: reported rule S0, needs Mike]
Unreleased bots say "Coming soon". Release status needs source evidence; no inference from a card or repository.

## Open policy gap

### GAP-01 Gold/white contrast

**Issue:** Current white button text on brand gold (`#EDAA4B`) has approximately 2.0:1 contrast ratio, which fails WCAG AA (requires 4.5:1 for normal text, 3:1 for large text).

**Evidence:**
- S4/S6 show white button text on brand gold
- S2 reports gold on white at 2.0:1
- GVS-TOKEN-005 in Marketing input flags this as a proposed accessibility conflict

**Options:**
1. Accept current contrast as brand decision (document as intentional deviation from WCAG AA)
2. Darken gold for text-bearing uses
3. Use brand-dark (`#9A6700`) for button backgrounds instead of gold
4. Use dark text on gold backgrounds

**Status:** Awaiting Mike's decision. Do not silently institutionalize or redesign.

## Documentation debt

Stale guides containing old CTA, pricing, infographic B, text-only, and diagram-dark instructions are superseded documentation debt, not new choices. These guides need updating to match the approved rules above:
- S1 voice-guide.md (agent-authored, DRAFT status)
- S4a historical UI guide (768px nav, old footer, stale API guidance)

## Debt and baseline entries

Existing debt items must have an owner, affected paths, target date or plan, and approval reference. A baseline entry prevents new drift but is not a permanent waiver.

| Owner | Paths | Rule | Reason | Target | Approval |
|-------|-------|------|--------|--------|----------|
| _To be filled when debt is identified_ | | | | | |

## Notes

- This file is DRAFT/NOT ENFORCED as of v1.0.0
- Only [APPROVED] rules may result in blocking findings
- All other rules are advisory and go under Notes
- Changing any [APPROVED] rule requires Mike's explicit approval
- Promoting a [PROPOSED] rule to [APPROVED] requires Mike's decision with source citation
