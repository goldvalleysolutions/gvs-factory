# Review · <repo> PR #<pr_number> · round <round_number>

_Run by a reviewer that did not write the code. Save as `review-round-<round_number>.md` with the job and link it from the pull request._

**Reviewed:** head `<sha>` against the acceptance checklist in spec `<path>`. The build report is a list of claims; the evidence run below checks them.
**Reviewer:** <name or agent> · **Date and time:** <...>
**Standards version:** <version from repo's STANDARDS.md>

## Reviewer inputs (sanitized bundle)

Every lens receives exactly the same bundle, with no builder commentary or prior-round findings. See `docs/process.md` section "Reviewer inputs (sanitized bundle)" for the full definition.

1. **Diff** — the patch file between base and head SHAs.
2. **Acceptance criteria** — the spec's checklist with the evidence run results attached (pass/fail per item).
3. **Standards** — the pinned standards version and all applicable profiles from the repo's STANDARDS.md, plus any declared reference files.
4. **Evidence pack** — raw `verify-local.sh` output and screenshots from the evidence run at the head SHA. No builder report, no developer commentary, no previous reviewer findings or conclusions.
5. **Lens instructions** — only the instructions for that lens (below).

In rounds 2 and 3, reviewers get a fresh bundle for the new head. Prior findings are used only by the orchestrator after verdicts are in, to check closure. No reviewer sees them.

### Isolation

**Enforced:** Each lens is a NEW cloud-agent launch, never a reply to the builder or a continued session, so it inherits no conversation context. Its input is the bundle above.

**Procedural only:** A cloud agent launches with repository access. It could technically run `git log`, read commit messages, or open the PR, and it could see branch names.

**Mitigations:**
- Reviewers start on a neutral review ref: a detached HEAD at the PR's base SHA, so the PR is not named in the prompt.
- The instruction not to read history or the PR is repeated in every lens prompt.
- Each report must state the files and commands it used; any reference to commit messages or the PR body voids that lens.

**What "voids" means:** The orchestrator discards that lens's verdict and relaunches a fresh lens. A voided lens never counts as a PASS.

**Residual risk:** True sandboxing (no repo access, only the bundle) is not available. The design records this rather than claiming it.

## Ground rules
1. **Run it once, before the lenses.** Outside the lens runs, the Reviewer checks out the branch, runs the check commands from `AGENTS.md` (or `scripts/verify-local.sh`), runs the tests including the Playwright e2e suite under `tests/e2e/` (desktop and mobile projects, stub LLM; record passes per project and the head SHA), and starts the app for anything a user or another system can see. Record pass/fail evidence for each item on the spec's acceptance checklist, reproducing at least one yourself. If you could not run something, say so and why. Then run each lens fresh and stateless with only the sanitized bundle. A lens never sees another lens's output; combine the verdicts only after all five return.
2. **Each lens gets its own verdict line**, exactly `VERDICT: PASS` or `VERDICT: CHANGES`.
3. **CHANGES only for real problems:** a bug, a spec gap, a failing check, a security issue, a standards violation with a rule ID, or a clear convention break. A failing check is always CHANGES.
4. **Do not block on taste.** Style preferences, naming and "nice to have" ideas go under Notes, never Findings.
5. **Do not block on pre-existing issues** the PR did not make worse; mention them under Notes.
6. From round 2, the evidence run re-checks every finding from the previous round and records fixed or not fixed on the checklist; each lens judges it from there.
7. Findings give `path:line`, the problem (with rule ID if a standards violation), its impact and the fix you want. Write "None." when there are none.
8. **Do not read git history, commit messages, or the PR description.** Judge only what is in the bundle. Any reference to history voids this lens.

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

_Look at: every AC in the spec has a test or a reproducible check; any new user-facing behaviour adds or updates Playwright e2e tests under `tests/e2e/` in this PR (missing e2e coverage is CHANGES); the e2e suite PASSes on desktop and mobile in the evidence run, with screenshot and trace saved on failure; tests fail without the change (spot-check one by reverting it locally); the new tests run in the local verification; no network or paid calls in tests; timer logic tested with controlled time, not sleeps; existing suites still pass unchanged._

### Findings
### Notes

## Lens 4 · UX
VERDICT: PASS | CHANGES

_Look at, with the app running: the flow does what the spec promises with no dead ends; loading, empty, error and expired states say something useful; copy is short, plain and consistent; real buttons and links, labels, keyboard use; works at phone width (390 px). If the PR has no user-facing change, write PASS and say so._

### Findings
### Notes

## Lens 5 · Consistency
VERDICT: PASS | CHANGES

_This lens is BLOCKING. Look at: the change follows the pinned standards version and all applicable profiles declared in the repo's STANDARDS.md; any new pattern matches or extends the declared reference files; a violation of an [APPROVED] rule is CHANGES with the rule ID cited; a violation of a [PROPOSED] rule goes under Notes, not Findings; any new deviation has an entry in DEVIATIONS.md with Mike's approval reference before merge; existing baselined deviations are not made worse; no new drift is introduced without approval._

### Findings
### Notes

## Round result
- **All five PASS and a Local verification block with no FAIL on the same head** → an agent merges to `test`; the PM agent writes the ready-to-merge note.
- **Any CHANGES and rounds left** (max 3 rounds: round 1 plus 2 rework rounds) → the developer agent resumes the builder with this file.
- **Any CHANGES after round 3** → stop; the PM agent writes the ready-to-merge note marked **NOT READY** with the open findings, for the human to decide.

---

_Template source: gvs-factory/templates/review.md_
