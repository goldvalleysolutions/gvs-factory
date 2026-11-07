# Bot architecture rules

**Approved:** Mike, Nov 1, 2026

This document records the architectural decisions for Gold Valley Solutions bot products that Mike approved on November 1, 2026.

## Architecture principles

The following rules are **[APPROVED]** and enforced by Lens 5:

### BOT-01 One image per bot
Each bot ships as a single Docker Hub image. No compose file, no sidecar services, no separate database server, no complex config.

### BOT-02 Pull and run
The user's whole setup is `docker pull` then `docker run`. Nothing is needed beyond Docker running: no cloning, no building, no exotic setup.

### BOT-03 Built on Core
Every bot is `FROM` the common Bot Core (`goldvalleysolutions/core-bot`) image.

### BOT-04 Core + job layer
A bot adds only what its job needs: role prompt, skills, tools, and the third-party integrations its job requires. Anything generic (chat, approvals, memory, admin, scheduling, storage, logging) belongs in Core.

### BOT-05 Same shape everywhere
All bots share the same structure and patterns: the `bot/` pack with role.md, bot.yaml, skills/, tools/, and theme.yaml. There are no one-off architectures.

## Known gaps

### Resident Front Desk deviation
Resident Front Desk is an 8-container compose stack that does not yet meet these rules. It must be rebuilt to comply. This is tracked debt, not an exception. Front Desk implementation is held from this review scope.

---

_Source: Mike's direct approval, Nov 1, 2026_
