# Review · <repo> PR #<n> · round <N>

_Run by a reviewer that did not write the code. Save as `review-round-<N>.md` with the job and link it from the pull request._

**Reviewed:** head `<sha>` against the acceptance checklist in spec `<path>`. The build report is a list of claims; the evidence run below checks them.
**Reviewer:** <name or agent> · **Date and time:** <...>

## Ground rules
1. **Run it once, before the lenses.** Outside the lens runs, the Reviewer checks out the branch, runs the check commands from `AGENTS.md` (or `scripts/verify-local.sh`), runs the tests, and starts the app for anything a user or another system can see. Record pass/fail evidence for each item on the spec's acceptance checklist, reproducing at least one yourself. If you could not run something, say so and why. Then run each lens fresh and stateless with only the diff, the checklist with this evidence, and its own lens section below. A lens never sees another lens's output; combine the verdicts only after all four return.
2. **Each lens gets its own verdict line**, exactly `VERDICT: PASS` or `VERDICT: CHANGES`.
3. **CHANGES only for real problems:** a bug, a spec gap, a failing check, a security issue, or a clear convention break. A failing check is always CHANGES.
4. **Do not block on taste.** Style preferences, naming and "nice to have" ideas go under Notes, never Findings.
5. **Do not block on pre-existing issues** the PR did not make worse; mention them under Notes.
6. From round 2, the evidence run re-checks every finding from the previous round and records fixed or not fixed on the checklist; each lens judges it from there.
7. Findings give `path:line`, the problem, its impact and the fix you want. Write "None." when there are none.

## Commands run
| Command | Result |
|---|---|
| `<command>` | pass/fail, key output |

## Lens 1 · Security
VERDICT: PASS | CHANGES

_Look at: auth on every new endpoint; signed links (signing, expiry, tampering, replay); constant-time comparisons; input validation (no user input into SQL, shell, file paths or templates unescaped); XSS in any HTML; secrets or `.env` values in commits; data exposure (personal data masked in logs and pages); outbound calls to real providers; new dependencies (needed? maintained?); bind addresses and exposed ports._

### Findings
1. <path:line> <problem, impact, fix>
### Notes

## Lens 2 · Code
VERDICT: PASS | CHANGES

_Look at: does what the spec requires and nothing more; edge cases, missing awaits, unhandled errors, swallowed exceptions; reuse of existing helpers and patterns; conventions in `AGENTS.md` and neighbouring code; docs and `.env.example` updated; commits are small and nothing stray is committed._

### Findings
### Notes

## Lens 3 · Tests and evals
VERDICT: PASS | CHANGES

_Look at: every AC in the spec has a test or a reproducible check; tests fail without the change (spot-check one by reverting it locally); the new tests run in the local verification; no network or paid calls in tests; timer logic tested with controlled time, not sleeps; existing suites still pass unchanged._

### Findings
### Notes

## Lens 4 · UX
VERDICT: PASS | CHANGES

_Look at, with the app running: the flow does what the spec promises with no dead ends; loading, empty, error and expired states say something useful; copy is short, plain and consistent; real buttons and links, labels, keyboard use; works at phone width (390 px). If the PR has no user-facing change, write PASS and say so._

### Findings
### Notes

## Round result
- **All four PASS and a Local verification block with no FAIL on the same head** → an agent merges to `test`; the PM agent writes the ready-to-merge note.
- **Any CHANGES and rounds left** (max 3 rounds: round 1 plus 2 rework rounds) → the developer agent resumes the builder with this file.
- **Any CHANGES after round 3** → stop; the PM agent writes the ready-to-merge note marked **NOT READY** with the open findings, for the human to decide.
