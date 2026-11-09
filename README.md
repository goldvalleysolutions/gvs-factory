# Gold Valley Solutions Software Factory

This repo defines a software factory: a process for turning ideas into working software with a team of AI agents and one human approver. It holds the process, the templates each step uses, and a few generic standards. It contains no project code.

## How it works

1. **Request and brief.** A PM agent ranks the request and writes a one-page brief. The human approves it.
2. **Spec.** The PM agent writes a spec. Every acceptance criterion has a Verify line that says how to check it.
3. **Architect handoff.** The Chief architect pins standards, selects patterns, and writes the acceptance-to-test matrix before the build.
4. **Build.** A developer agent builds on a branch, opens a pull request into `test`, and writes a build report (claims only).
5. **Independent checks.** A Reviewer executes the matrix on the exact committed head, then four lenses (Security, Code, Tests and evals, UX/Consistency) judge one sanitized bundle. Any CHANGES sends the work back, up to three rounds. After round 3, stop; the human decides. Agents must not start round 4.
6. **Merge to test.** When all four lenses pass, Local verification PASSes, and the test matrix was executed on the same head, an agent merges to `test`. CI only builds, publishes and deploys.
7. **Human check.** The human gets a short ready-to-merge note, tries the change, and is the only one who merges `test` into `main`.

Money, auth and permissions, deploys, database changes, messages to real people, new dependencies, public exposure and business decisions are always flagged for the human.

The full process is in `docs/process.md`.

## Repo layout

```
LICENSE
NOTICE
README.md
AGENTS.md                 pointers to process, DoD, and verify-local.sh
docs/
  process.md              the process: roles, flow, gates, review lenses, rework and merge rules
standards/
  ci-minutes.md           local verification and the little CI that remains
  definition-of-done.md   when a change counts as done
templates/
  spec.md                 build spec with acceptance criteria and Verify lines
  architect-handoff.md    pinned standards, patterns, and matrix link
  test-matrix.md          positive, negative, and environment cases
  lessons-log.md          lessons with disposition and approval
  build-report.md         the builder's report, first line is the status
  review.md               four-lens review, one verdict per lens
  ready-to-merge.md       the short note the human reads before merging
scripts/
  verify-local.sh         runs all checks locally and prints the Local verification block
```

## Local verification

All validation runs locally before a merge to `test` (see `standards/ci-minutes.md`). From the root of the repo under test, on a clean tree at the commit you want to merge:

```
bash /path/to/gvs-factory/scripts/verify-local.sh            # auto-detects stacks in . and in subdirectories
VERIFY_DIRS="frontend backend" bash scripts/verify-local.sh  # pick the directories yourself
bash scripts/verify-local.sh --allow-missing                 # local debug only; not merge acceptance
VERIFY_COMPOSE_TEST="curl -fsS localhost:8080/health" bash scripts/verify-local.sh  # compose up --wait, test, compose down -v
VERIFY_E2E_CMD="npx playwright test" bash scripts/verify-local.sh                   # e2e tests (default when tests/e2e/ exists; against the stack if there is one)
```

It detects npm and Python projects, Dockerfiles (`docker build` + `trivy image`) and compose files, always runs gitleaks and Semgrep (`p/ci`, or `SEMGREP_CONFIG`), and prints a Markdown block to paste into the pull request. It exits non-zero if any check fails or the tree is dirty.

## Credits

The process was inspired by public discussion of AI software factories. Gold Valley Solutions took ideas, not files. All documents here are original work.

## License

Apache License 2.0. See `LICENSE` and `NOTICE`.
