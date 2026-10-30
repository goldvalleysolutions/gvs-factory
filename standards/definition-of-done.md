# Definition of done

A change is done when every item below is true. The PM agent checks items 1 to 8 before writing the ready-to-merge note. The human checks item 9.

1. **Criteria met with evidence.** Every acceptance criterion in the spec passes, with reviewer or Local verification evidence. The builder's own report does not count as evidence.
2. **Local verification on the exact head.** The pull request has a Local verification block with no FAIL, run on the commit being merged (see `standards/ci-minutes.md`). No stacked pull requests.
3. **Four lenses pass.** Security, code, tests and evals, and UX each have `VERDICT: PASS` on that same commit, within 3 review rounds.
4. **Scope held.** No files changed outside the spec's areas. Out-of-scope items are untouched.
5. **No secrets or real personal data.** No keys, tokens or `.env` files committed. Examples use fictional data.
6. **Docs updated.** README, `AGENTS.md` and example config reflect any changed behaviour.
7. **Flags named.** Every always-flagged item the change touches is listed in the ready-to-merge note, and any product decisions are defaults in config, not hard-coded.
8. **Playwright e2e suite passes.** The repo's `tests/e2e/` Playwright suite (desktop and mobile, stub LLM) PASSes in `scripts/verify-local.sh` on the head, the Local verification block shows passes per project and the head SHA, and any new user-facing behaviour has new or updated e2e tests in this pull request. See the rule below.
9. **Human approval.** The human has tried the change on `test` and merged it to `main`.

## Playwright end-to-end rule (Mike, 2026-10-30)

Standing rule for core and every bot repo:

1. All user-facing testing uses Playwright.
2. The repo keeps a committed Playwright e2e suite under `tests/e2e/`. It runs on a desktop and a mobile project, with the stub LLM by default.
3. The suite has one opt-in live-provider smoke test, behind a marker or env flag, using a cheap model. Keys are never logged.
4. Every failure saves a screenshot and a trace.
5. `scripts/verify-local.sh` runs the suite, and it must PASS before any merge to `test`.
6. The pull request's Local verification block lists the suite result (passes per project) and the head SHA.
7. The Reviewer's evidence run includes the suite.
8. Any new user-facing behaviour adds or updates its e2e tests in the same pull request.
