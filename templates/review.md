# Review · <repo> PR #<n> · round <N>

_Run by a reviewer that did not write the code. Save as `review-round-<N>.md` with the job and link it from the pull request._

**Reviewed:** head `<sha>` against the acceptance checklist in spec `<path>`.
**Test matrix:** `<path to test-matrix.md>`
**Reviewer:** <name or agent> · **Date and time:** <...>

## Ground rules
1. **Execute the test matrix first.** Before the lens runs, the Reviewer executes the test matrix (`templates/test-matrix.md`) on the exact head commit. Record the head SHA, environment, and raw outputs in the matrix. This is the evidence; the builder's report is claims only and does not substitute.
2. **Run the verification suite.** Check out the branch, run the check commands from `AGENTS.md` (or `scripts/verify-local.sh`), run the tests including the Playwright e2e suite under `tests/e2e/` (desktop and mobile projects, stub LLM; record passes per project and the head SHA), and start the app for anything a user or another system can see. Record pass/fail evidence for each item on the spec's acceptance checklist, reproducing at least one yourself. If you could not run something, say so and why.
3. **Run each lens fresh and stateless.** Each lens sees only the diff, the sanitized bundle, and the matrix evidence. A lens never sees the builder's narrative, the build report claims, or prior verdicts. A lens never sees another lens's output. Combine the verdicts only after all four return.
4. **Each lens gets its own verdict line**, exactly `VERDICT: PASS` or `VERDICT: CHANGES`.
5. **CHANGES only for real problems:** a bug, a spec gap, a failing check, a security issue, or a clear convention break. A failing check is always CHANGES.
6. **Do not block on taste.** Style preferences, naming and "nice to have" ideas go under Notes, never Findings.
7. **Do not block on pre-existing issues** the PR did not make worse; mention them under Notes.
8. From round 2, the evidence run re-checks every finding from the previous round and records fixed or not fixed on the checklist; each lens judges it from there.
9. Findings give `path:line`, the problem, its impact and the fix you want. Write "None." when there are none.

## Test matrix execution
_Executed on head `<sha>` before the lens runs. See the full matrix at `<path to test-matrix.md>`._

**Environment:**
- OS: <...>
- Shell: <...>
- Python version: <...>
- Node version (if applicable): <...>

**Summary:**
- Total cases: <n>
- Passed (actual matched expected): <n>
- Failed (actual did not match expected): <n>

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

_Look at: backend architecture and code consistency; does what the spec requires and nothing more; edge cases, missing awaits, unhandled errors, swallowed exceptions; reuse of existing helpers and patterns; conventions in `AGENTS.md` and neighbouring code; docs and `.env.example` updated; commits are small and nothing stray is committed._

### Findings
### Notes

## Lens 3 · Tests and evals
VERDICT: PASS | CHANGES

_This lens verifies the test matrix results and must list the commands it ran. "Commands run: None" cannot PASS._

_Look at: the test matrix was executed independently on the exact head, with raw outputs recorded; re-execute at least the negative and environment cases from the matrix; every AC in the spec has a test or a reproducible check; any new user-facing behaviour adds or updates Playwright e2e tests under `tests/e2e/` in this PR (missing e2e coverage is CHANGES); the e2e suite PASSes on desktop and mobile in the evidence run, with screenshot and trace saved on failure; tests fail without the change (spot-check one by reverting it locally); the new tests run in the local verification; no network or paid calls in tests; timer logic tested with controlled time, not sleeps; existing suites still pass unchanged._

### Matrix verification
| Case re-executed | Command | Expected | Actual | Match |
|---|---|---|---|---|
| AC-T1.1 negative | `<command>` | `<expected>` | `<actual>` | yes/no |
| AC-T1.1 environment | `<command>` | `<expected>` | `<actual>` | yes/no |

### Commands run
_List every command this lens executed. This section must not be empty._
| Command | Result |
|---|---|
| `<command>` | pass/fail, key output |

### Findings
### Notes

## Lens 4 · UX/Consistency
VERDICT: PASS | CHANGES

_Look at, with the app running: frontend patterns, flow, style, brand, accessibility and usability; the flow does what the spec promises with no dead ends; loading, empty, error and expired states say something useful; copy is short, plain and consistent; real buttons and links, labels, keyboard use; works at phone width (390 px). If the PR has no user-facing change, write PASS and say so._

### Findings
### Notes

## Round result
- **All four PASS and a Local verification block with no FAIL on the same head** → an agent merges to `test`; the PM agent writes the ready-to-merge note.
- **Any CHANGES and rounds left** (max 3 rounds: round 1 plus 2 rework rounds) → the developer agent resumes the builder with this file.
- **Any CHANGES after round 3** → stop; the PM agent writes the ready-to-merge note marked **NOT READY** with the open findings, for the human to decide.
