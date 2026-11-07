# Web profile · v1

Version: 1.0.0
Effective: 2026-11-07
Profiles: Applies to web frontend repositories (website, marketing pages). Repos declare this profile in their STANDARDS.md.

These rules apply to Gold Valley Solutions web frontends. **Bot repositories use profile-bot.md and do NOT inherit website layout.**

## Approved rules (blocking)

### WEB-01 Rulebook location [APPROVED: Mike, direct, Nov 2026]
The standards rulebook lives in `gvs-factory/standards`. Project repos pin a version and declare applicable profiles in their STANDARDS.md.

### WEB-02 Five independent review lenses [APPROVED: Mike, direct, Nov 2026]
Reviews use five independent lenses: Security, Code, Tests, UX, and Consistency. Each lens runs as a separate cloud-agent launch with the sanitized bundle.

## Candidate rules (non-blocking, under review)

These rules are derived from observed patterns but lack direct Mike approval. Violations go under Notes, not Findings. They require Mike's decision before enforcement.

### WEB-03 Base template shell [PROPOSED: observed from www@05346b0, needs Mike]
Web pages extend a common base template (`base.njk`) that provides the HTML shell, head elements, and shared layout structure. Pages should not duplicate this structure.

**Reference:** `www@05346b0` `frontend/src/_includes/base.njk` (nav lines 92-133, footer lines 137-180)

### WEB-04 Reference files in STANDARDS.md [PROPOSED: needs Mike]
The repo's STANDARDS.md declares which files are the reference implementations for components, layouts, and patterns. New code follows those references.

### WEB-05 Component location [PROPOSED: observed from S5, needs Mike]
Reusable components live in `_includes/` for Eleventy. One-off markup should be extracted if used more than once.

### WEB-06 Tailwind for styling [PROPOSED: observed from www@05346b0, needs Mike]
Styling uses Tailwind CSS utility classes. Custom CSS is limited to design tokens, base layer resets, and cases where utilities cannot express the style.

**Reference:** `www@05346b0` `frontend/tailwind.config.js` (tokens lines 6-20), `frontend/src/css/input.css`

### WEB-07 Design tokens in config [PROPOSED: observed from S5, needs Mike]
Colors, spacing scales, and typography settings are defined in the Tailwind config, not scattered across templates. Token names describe purpose, not appearance (e.g., `brand-gold`, not `yellow-500`).

### WEB-08 Responsive breakpoints [PROPOSED: observed from S5, needs Mike]
Header collapses at `xl` breakpoint. Mobile padding is `px-4 sm:px-6`, not universal `px-6`. Use current profile breakpoints; do not enforce old S4 768px breakpoint on the website.

### WEB-09 Panel alternation [PROPOSED: observed from S6, needs Mike]
Marketing sections use `panel-white`/`panel-clear` alternation. Do not require homepage hero/services/work/thoughts/contact order on every service page.

### WEB-10 Typography and content tests [PROPOSED: needs Mike]
Repos with web content maintain automated tests for typography rules and content lint. These run in `verify-local.sh`.

### WEB-11 Visual regression for templates [PROPOSED: needs Mike]
Changes to layout templates or shared components include before/after screenshots at desktop and 390px widths in the review.

## Website-specific families

The website has distinct page families. Do not use homepage as reference for every screen.

| Family | Reference | Application |
|--------|-----------|-------------|
| WEB-MARKETING | `base.njk`, theme, stylesheet | Marketing shell, services, portfolio, About, contact |
| WEB-BLOG-CLASSIC | `blog-classic.njk` | Foundations and Putting It to Work article families |
| WEB-BLOG-ENGINEERING | `blog-engineering.njk` | Behind the Build project articles |
| HOMEPAGE | Homepage-specific | Homepage flow is homepage-only, not universal pattern |
| TRAINING | Training-specific | Has its own CTA/content overrides |

## Documentation debt

S4a historical UI guide contains stale references (768px nav, old footer patterns). Current implementation verified from `www@05346b0` supersedes S4a. The guide needs updating.

## Notes

- Web profile applies only to web frontends, never to bot products
- Observed patterns are [PROPOSED], not [APPROVED]
- Never auto-convert an observed pattern into an approved rule
- Compare same family to same family (Foundations to Foundations, not homepage to service page)
