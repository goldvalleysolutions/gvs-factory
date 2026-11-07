# STANDARDS.md template

_Copy this to a project repo as `STANDARDS.md`. Fill in the version, profiles, and reference files._

# Standards pin

This repository follows the Gold Valley Solutions software factory standards.

## Version

**Standards version:** v1.0.0
**Pinned date:** <YYYY-MM-DD>
**Source:** https://github.com/goldvalleysolutions/gvs-factory/tree/test/standards/v1

## Applicable profiles

_Check all that apply. Each profile adds its rules to this repo's consistency review._

- [ ] `common.md` — applies to all repos (required)
- [ ] `profile-bot.md` — bot repositories only
- [ ] `profile-web.md` — web frontend repositories only
- [ ] `brand.md` — repos with user-facing visual interfaces (DRAFT — only [APPROVED] rules enforced)
- [ ] `blog.md` — repos with blog content (DRAFT — only [APPROVED] rules enforced)

### Profile decision

**Which profile applies to this repo?**

- **profile-bot** — A repo that ships a Docker image run with `docker run` is `profile-bot`, even if it has an admin web UI. The bot's web UI serves task completion, not public website pages.

- **profile-web** — A repo that ships public website pages (marketing, blog, portfolio) is `profile-web`. It does not apply to bot admin UIs.

A repo may declare both profiles only if it genuinely contains both a bot and a public website. Most repos declare one.

## Reference files

_List the files that are the reference implementation for this repo. New code follows these patterns._

A **reference file** is the canonical implementation of a pattern that others copy. When multiple files could implement a pattern, the reference file is the one that new code should match. List only files in this repo.

| Family/component | Reference path | Notes |
|------------------|----------------|-------|
| <e.g., base shell> | <e.g., src/_includes/base.njk> | <e.g., all pages extend this> |
| <e.g., blog post> | <e.g., thoughts/gold-valley-bots.md> | <e.g., new posts follow this structure> |
| | | |

## Project-specific rules

_Add any rules specific to this repo that are not in the factory standards. Each rule needs a unique ID (e.g., PROJ-01) and a source._

| ID | Rule | Source |
|----|------|--------|
| | | |

## Deviations

See `DEVIATIONS.md` for any approved deviations from the pinned standards.

## Updating the pin

1. Review the CHANGELOG in gvs-factory/standards/v1 for changes since the current pin.
2. Update the version and pinned date above.
3. Review any new rules against this repo's code.
4. Add baseline entries to DEVIATIONS.md for any new drift that requires approval.
5. Open a PR with the pin update.

---

_Template source: gvs-factory/templates/standards-pin.md_
