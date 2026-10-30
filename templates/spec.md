# Build spec: <project> · <pull request or job name>

_Copy this file, fill every section and delete the guidance lines in italics._
_Header lines: Repo · Base branch (`test`) · Items covered · Owner (PM agent) · Builder (developer agent) · Approver (human) · Status._

_Example used below: a fictional `notes-app` adding CSV export of notes._

## 1. Goal
_Two or three plain sentences: what is true for the user when this ships, and why it matters._

Example: Users can download all their notes as a CSV file from the notes list, so they can back them up or open them in a spreadsheet.

## 2. Context
_Where this lives in the code today. Cite real paths, classes and commands from the repo at the base commit; do not guess names. Name the existing patterns the builder must reuse._

Example: Notes are served by `app/routes/notes.py`; the list page is `app/templates/notes/list.html`. Reuse the existing `require_login` decorator.

## 3. Tasks
_One task per item. The builder works through them in order and commits per task. Each task has the blocks below._

### T1 · CSV export endpoint
**Requirements**
1. `GET /notes/export.csv` returns the signed-in user's notes as CSV with columns `id,title,body,created_at`.
2. Only the signed-in user's notes are included.

**Acceptance criteria**
_Each one is one observable behaviour plus how to check it, runnable by someone who only has the repo. No criterion without a Verify line._
- **AC-T1.1** A signed-in user gets a CSV of their own notes.
  **Verify:** `pytest tests/test_export.py::test_export_own_notes` → passes.
- **AC-T1.2** A signed-out request is refused.
  **Verify:** `curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/notes/export.csv` → `401`.
- **AC-T1.3** The notes list shows an "Export CSV" button that downloads the file.
  **Verify:** start the app, sign in as `demo@example.com`, open `/notes`, click "Export CSV"; expect a `notes.csv` download. Screenshot in the build report.

**Out of scope for this task**
- Import from CSV, other formats, scheduled exports.

## 4. Whole-PR acceptance criteria (always include)
- **AC-G.1** CI is green on the pull request's last commit (every job).
  **Verify:** CI checks on the head commit → all `success`.
- **AC-G.2** Lint and format pass locally with the exact CI commands from `AGENTS.md`.
  **Verify:** the commands → exit 0.
- **AC-G.3** No secrets, keys or real personal data are committed; `.env` is not committed.
  **Verify:** `git diff <base>...HEAD --name-only | grep -x .env` → no output; a secret scan of the diff → no findings.
- **AC-G.4** The default configuration makes zero paid or outbound calls to real providers.
  **Verify:** the named test or check for this repo.
- **AC-G.5** Docs updated where behaviour changed (README, `AGENTS.md`, `.env.example`).
  **Verify:** `git diff <base>...HEAD --stat` lists them; the reviewer reads them.

## 5. Out of scope (whole PR)
- _Paid services, public exposure, new providers, refactors not required by a task, later items._

## 6. Assumptions
_Decisions made where the request was ambiguous, one line each, with a reason. Mark each **[product decision → human]** or **[technical]**. Product decisions become defaults in config, never hard-coded, and are listed in the ready-to-merge note._

Example: CSV uses UTF-8 with a header row [technical].

## 7. Always-flagged items expected in this PR
_Tick the ones this PR will trigger, so the human knows where to look first. The full list is in `docs/process.md`._
- [ ] Auth, permissions, signed links, secrets handling
- [ ] Money: paid services, API keys, spend, anything that could bill
- [ ] Deploy or runtime config: containers, CI workflows, build scripts, ports or bind addresses
- [ ] Database schema (new or changed tables or columns, migrations)
- [ ] Messages to real people or real providers (email, SMS, voice, outbound webhooks)
- [ ] New dependency
- [ ] Public exposure (opening network access, making a repo public, publishing)
- [ ] Safety-critical logic
- [ ] Product or business decision (thresholds, prices, public copy)

## 8. Definition of Ready (PM agent ticks before build)
- [ ] Every AC has a Verify line with an exact command or check
- [ ] Out of scope listed per task and for the whole PR
- [ ] Assumptions marked product vs technical
- [ ] Expected flags ticked
- [ ] Repo has `AGENTS.md` (or a task adds it)
- [ ] The human approved the spec (date)
