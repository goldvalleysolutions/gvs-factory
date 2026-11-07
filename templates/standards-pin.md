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
- [ ] `brand.md` — repos with user-facing visual interfaces (DRAFT/NOT ENFORCED)
- [ ] `blog.md` — repos with blog content (DRAFT/NOT ENFORCED)

## Reference files

_List the files that are the reference implementation for this repo. New code follows these patterns._

| Family/component | Reference path | Notes |
|------------------|----------------|-------|
| <e.g., base shell> | <e.g., src/_includes/base.njk> | <e.g., all pages extend this> |
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
