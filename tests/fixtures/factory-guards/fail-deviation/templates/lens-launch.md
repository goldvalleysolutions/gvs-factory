# Lens launch template

_Prompt template for launching a review lens as a new cloud-agent run. Each lens gets its own launch with the sanitized bundle._

---

## Launch steps

1. **Start a NEW Cursor cloud agent** on the repo at a detached HEAD at the PR's base SHA `<base_sha>` (an exact commit, never a branch name). This ensures the reviewer has no access to the PR branch name or head commits in its default checkout.

2. **Attach the sanitized bundle** as files:
   - The diff as a patch file: `gh api -H "Accept: application/vnd.github.v3.diff" repos/{owner}/{repo}/compare/{base}...{head} > bundle.diff`
   - The acceptance criteria with evidence results
   - The standards text (see below)
   - The evidence pack (verify-local output + screenshots)
   - Each reference file declared in the repo's STANDARDS.md pin, appended with a `--- <path> ---` header.

   **How to attach:** Save each bundle file on the orchestrator's machine. Pass them in the CloudAgent launch `files` parameter as `file://` URLs. The agent finds them under `uploads/`. Never paste the diff into the PR or the prompt.

   **Evidence scrubbing:** Before attaching the evidence pack, redact secrets, tokens, `.env` values, and personal data from command output and screenshots. Manual screenshot review is still required.

3. **Use this prompt template** with the lens-specific instructions.

4. **Record provenance** in the project repo's `review/<pr_number>-round<round_number>.json`:
   - Agent ID and URL
   - Requested model (from the launch)
   - Reported model (from platform; may be "not reported")
   - Head SHA, base SHA, and standards version

---

## Lens <lens_number> · <Lens name>

You are a reviewer running Lens <lens_number> (<lens name>) for base `<base_sha>` to head `<head_sha>` in <repo>, round <round_number>.

**This is a review-only run. Do not read the PR body, comments, or commit messages. Do not run git log. Judge only what is in the attached bundle.**

### Your inputs (sanitized bundle)

You have been given exactly these inputs (see `docs/process.md` section "Reviewer inputs" for the full definition):

1. **Diff** — the patch file between base SHA `<base_sha>` and head SHA `<head_sha>`.
2. **Acceptance criteria** — the spec's checklist with evidence run results attached (pass/fail per item).
3. **Standards** — the full text of `common.md` plus each declared profile from the repo's STANDARDS.md, concatenated with file headers (e.g., `--- common.md ---`).
4. **Evidence pack** — scrubbed `verify-local.sh` output and screenshots from the evidence run at head SHA. No builder report, no developer commentary, no previous reviewer findings.
5. **These instructions** — only the instructions for this lens.

You do NOT have:
- The builder's report or commentary
- Previous reviewer findings
- Prior round findings (the orchestrator checks closure after all verdicts)
- Another lens's output

### Ground rules

1. **Do not read git history, commit messages, or the PR description.** Judge only what is in the bundle. Any reference to history voids this lens.
2. **Output exactly one verdict line:** `VERDICT: PASS` or `VERDICT: CHANGES`
3. **CHANGES only for real problems:** a bug, a spec gap, a failing check, a security issue, a standards violation with rule ID, or a clear convention break.
4. **Only [APPROVED] rules are blocking.** Violations of [PROPOSED] rules go under Notes, not Findings.
5. **Do not block on taste.** Style preferences go under Notes.
6. **Do not block on pre-existing issues** the PR did not make worse.
7. **Findings cite:** `path:line`, problem, rule ID (if standards violation), impact, fix.
8. **State files and commands you used.** Any undisclosed repo access voids this lens. ("Voids" means the orchestrator discards that verdict and relaunches a fresh lens. A voided lens never counts as a PASS.)

### Lens-specific instructions

Paste only the italic paragraph under the matching `## Lens N · <name>` heading in `templates/review.md`. Do not paste other lenses or extra sections.

### Output format

```markdown
## Lens <lens_number> · <Lens name>
VERDICT: PASS | CHANGES

### Findings
1. <path:line> <problem, rule ID, impact, fix>
   (or "None.")

### Notes
<non-blocking observations>

### Files and commands used
<list what you accessed>
```

---

## Standards input format

The standards input is the full text of `common.md` plus each declared profile, concatenated with file headers:

```
--- common.md ---
<full text of common.md>

--- profile-bot.md ---
<full text of profile-bot.md, if declared>

--- profile-web.md ---
<full text of profile-web.md, if declared>

--- brand.md ---
<full text of brand.md, if declared>

--- blog.md ---
<full text of blog.md, if declared>
```

Only include profiles declared in the repo's STANDARDS.md. Then append each declared reference file, each preceded by a `--- <path> ---` header line.

---

## Orchestrator notes

_For the orchestrator launching lens runs:_

1. Launch each lens as a **NEW cloud-agent** on the repo at a detached HEAD at the PR's base SHA `<base_sha>` (an exact commit, never a branch name), not a reply or continued session.
2. All five lenses get the same sanitized bundle.
3. Do not include prior findings in any lens input.
4. Wait for all five verdicts before combining.
5. Record provenance in the project repo's `review/<pr_number>-round<round_number>.json` using the schema.
6. Check closure against prior findings only after all verdicts are in.

### Model selection

- Reviewers run on a different model from the builder where available.
- If no different model is available, record "same model as builder" in provenance.
- Only models on the existing plan are used.
- Record both requested model and reported model (platform may report "not reported").

---

_Template source: gvs-factory/templates/lens-launch.md_
