# Standards pin

This repository follows the Gold Valley Solutions software factory standards.

## Version

**Standards version:** v1.0.0
**Pinned date:** 2026-11-07
**Source:** https://github.com/goldvalleysolutions/gvs-factory/tree/v1.0.0/standards/v1

**Immutability:** The factory's `standards/v1/` folder is immutable once released; changes go in `v2/`.

## Applicable profiles

- [x] `common.md` — always included (applies to all repos)
- [x] `profile-bot.md` — bot repositories only
- [ ] `profile-web.md` — web frontend repositories only
- [ ] `brand.md` — repos with user-facing visual interfaces (DRAFT — only [APPROVED] rules enforced)
- [ ] `blog.md` — repos with blog content (DRAFT — only [APPROVED] rules enforced)

## Reference files

| Family/component | Reference path | Notes |
|------------------|----------------|-------|
| Bot config | bot/bot.yaml | Main bot configuration |
| Theme | bot/theme.yaml | Color and font overrides |

## Pre-review verification

Before launching a review panel, run the factory guards from the pinned version:

```bash
# From gvs-factory at the pinned tag or commit:
scripts/run-factory-guards.sh

# Or via verify-local which includes the guards:
scripts/verify-local.sh
```

Required guards fail closed: missing dependencies (python3, jsonschema>=4.18) are FAIL, never SKIP.

## Deviations

See `DEVIATIONS.md` for any approved deviations from the pinned standards.
