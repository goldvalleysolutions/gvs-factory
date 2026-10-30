# Definition of done

A change is done when every item below is true. The PM agent checks items 1 to 7 before writing the ready-to-merge note. The human checks item 8.

1. **Criteria met with evidence.** Every acceptance criterion in the spec passes, with reviewer or CI evidence. The builder's own report does not count as evidence.
2. **CI green on the exact head.** All CI jobs pass on the commit being merged. No stacked pull requests.
3. **Four lenses pass.** Security, code, tests and evals, and UX each have `VERDICT: PASS` on that same commit, within 3 review rounds.
4. **Scope held.** No files changed outside the spec's areas. Out-of-scope items are untouched.
5. **No secrets or real personal data.** No keys, tokens or `.env` files committed. Examples use fictional data.
6. **Docs updated.** README, `AGENTS.md` and example config reflect any changed behaviour.
7. **Flags named.** Every always-flagged item the change touches is listed in the ready-to-merge note, and any product decisions are defaults in config, not hard-coded.
8. **Human approval.** The human has tried the change on `test` and merged it to `main`.
