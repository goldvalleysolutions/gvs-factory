# Common standards · v1

Version: 1.0.0
Effective: 2026-11-07
Profiles: Applies to all Gold Valley Solutions repositories.

These rules apply to every repo regardless of its profile. Profile-specific rules are in their own files.

## Code patterns

### CM-01 No secrets in commits [APPROVED: docs/process.md lines 113-114, standards/definition-of-done.md line 10]
No keys, tokens, `.env` files, or credentials committed to the repository. Examples and tests use fictional data only.

### CM-02 Docs updated with changes [APPROVED: standards/definition-of-done.md line 11]
README, `AGENTS.md`, and example config reflect any changed behaviour in the same pull request.

### CM-03 One change per pull request [APPROVED: docs/process.md lines 50-51]
Each pull request targets `test` and makes one logical change. No stacked pull requests.

### CM-04 Local verification on exact head [APPROVED: standards/ci-minutes.md, standards/definition-of-done.md line 7]
The pull request has a Local verification block with no FAIL, run on the exact commit being merged.

### CM-05 Evidence over self-report [APPROVED: docs/process.md line 8]
Only reviewer evidence and Local verification count. The builder's own report is claims to check, not proof.

### CM-06 Three-round cap [APPROVED: docs/process.md lines 100-105]
Maximum three review rounds (round 1 plus two rework rounds). Any CHANGES after round 3 goes to the human.

### CM-07 Human owns main [APPROVED: docs/process.md line 11, line 63]
Agents may merge to `test`. Only the human merges `test` into `main`.

### CM-08 Always-flagged items require human approval [APPROVED: docs/process.md lines 108-127]
Auth, permissions, signed links, secrets handling, money/paid services, deploy or runtime config, database schema changes, messages to real people or providers, writing production data, new dependencies, public exposure, safety-critical logic, and product or business decisions always go to the human, even when every lens passes.

## Testing

### CM-09 Playwright e2e for user-facing testing [APPROVED: standards/definition-of-done.md lines 16-23]
All user-facing testing uses Playwright. The repo keeps a committed suite under `tests/e2e/`, runs on desktop and mobile with the stub LLM by default, has one opt-in live-provider smoke test, and every failure saves a screenshot and trace.

### CM-10 New user-facing behaviour needs e2e tests [APPROVED: standards/definition-of-done.md line 23]
Any new user-facing behaviour adds or updates its e2e tests in the same pull request.

### CM-11 No network or paid calls in tests [APPROVED: templates/review.md line 40]
Tests run without network or paid service calls. Timer logic uses controlled time, not sleeps.

## Process

### CM-12 Testable acceptance criteria [APPROVED: docs/process.md line 7]
Every acceptance criterion is one observable behaviour plus a Verify line that says exactly how to check it, using only the repo.

### CM-13 Scope held [APPROVED: standards/definition-of-done.md line 9]
No files changed outside the spec's areas. Out-of-scope items are untouched.

### CM-14 Flags named in ready-to-merge [APPROVED: standards/definition-of-done.md line 12]
Every always-flagged item the change touches is listed in the ready-to-merge note, and any product decisions are defaults in config, not hard-coded.

## Review

### CM-15 Five independent lenses [APPROVED: Mike, direct, Nov 2026]
Reviews use five independent lenses: Security, Code, Tests and evals, UX, and Consistency. Each lens runs as a NEW cloud-agent launch with the sanitized bundle. All five must PASS before merge to `test`.

### CM-16 Consistency lens blocking [APPROVED: Mike, direct, Nov 2026]
The Consistency lens (Lens 5) is BLOCKING from day one. It checks the change against the pinned standards version and all applicable profiles. Violations of [APPROVED] rules are CHANGES with the rule ID cited. Violations of [PROPOSED] rules go under Notes, not Findings.
