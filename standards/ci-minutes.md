# CI minutes standard

Version 2 (2026-10-30). Supersedes version 1.

CI minutes are a limited budget. All validation runs locally, before any merge to `test`. CI keeps only the work that must run on the hosted Git service.

## 1. Local verification

Before a pull request is merged to `test`, the developer agent runs every check locally on the exact head commit:

- Lint and type checks
- Unit tests
- Functional and end-to-end tests
- Security: gitleaks (secrets), Semgrep (free rules, `p/ci`), `npm audit` or `pip-audit` (dependencies), and Trivy (`HIGH,CRITICAL`, `--ignore-unfixed`) on every image built from a Dockerfile
- Container checks: build each Dockerfile; when the repo has a compose file, bring the stack up and test against it

Docker is required whenever the repo has a Dockerfile or the compose variables are set. Without it the row is `MISSING`.

### Container variables

The factory knows no project names. Each project sets these in its `AGENTS.md` or verify command:

| Variable | Effect |
|---|---|
| `VERIFY_COMPOSE_FILE` | Compose file to use. Default: the first of `compose.yaml`, `compose.yml`, `docker-compose.yaml`, `docker-compose.yml` at the root |
| `VERIFY_COMPOSE_TEST` | Command run against the stack: `docker compose up -d --build --wait`, the command, then `docker compose down -v` (always) |
| `VERIFY_E2E_CMD` | End-to-end command, for example `npx playwright test`. Runs while the stack is up, or on its own when there is no compose file |
| `SEMGREP_CONFIG` | Semgrep rules. Default `p/ci` |
| `VERIFY_DIRS` | Directories to check. Default: `.` and first-level subdirectories with a project file |
| `VERIFY_DOCKER_TARGET` | Build target for the root `Dockerfile` of each checked directory |
| `VERIFY_DOCKERFILES` | Extra Dockerfiles to build and scan, for example `Dockerfile.worker` |
| `VERIFY_DOCKER_BUILD_ARGS` | Extra `docker build` flags, for example `--network host` |
| `VERIFY_SKIP` | Checks to skip (first word of the row, e.g. `mypy`); the row shows `SKIP` with `VERIFY_SKIP_REASON` (default "not part of this repo's gate"). Name each skip in the pull request |

`VERIFY_COMPOSE_TEST` and `VERIFY_E2E_CMD` get `COMPOSE_PROJECT_NAME` and `COMPOSE_FILE` in their environment, so plain `docker compose ...` calls inside them hit the script's stack. A repo can commit these settings in `.verify-local.env` (`KEY=VALUE` lines; only `VERIFY_*` and `SEMGREP_CONFIG` are read, the file is never sourced, and the environment wins).

`scripts/verify-local.sh` runs these and prints the block below. Paste it into the pull request description.

### Block format

- Title `## Local verification`
- Repo, branch, head SHA (`git rev-parse HEAD`), time, and a dirty-tree line
- A table with one row per command: command, result (`PASS`, `FAIL` or `SKIP` with a reason), duration
- An overall line: `Overall: PASS` or `Overall: FAIL`

### Example (fictional)

```markdown
## Local verification

- Repo: example-app
- Branch: feature/add-login
- Head SHA: 0123456789abcdef0123456789abcdef01234567
- Tree: clean
- Time: 2026-10-30 14:05 America/New_York

| Command | Result | Duration |
|---|---|---|
| `npm ci` | PASS | 21s |
| `npm run lint` | PASS | 6s |
| `npm run typecheck` | PASS | 9s |
| `npm test` | PASS | 14s |
| `npm run test:e2e` | PASS | 48s |
| `npm audit --audit-level=high` | PASS | 3s |
| `gitleaks dir` | PASS | 1s |
| `semgrep scan --config p/ci --error` | PASS | 30s |
| `docker build` | PASS | 40s |
| `trivy image --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1` | PASS | 12s |

Overall: PASS
```

## 2. Merge rule

- No Local verification block, a block with any `FAIL`, or a block on a SHA other than the pull request's head means **no merge**.
- Any new commit needs a new block.
- `MISSING` tools count as `FAIL` unless the gap is named in the pull request and accepted by the human.
- Agents merge to `test`. Only the human merges to `main`.

## 3. What CI keeps

- **Build and publish images** to the container registry on `push` to `test` or `main`, with `paths` filters limited to the Dockerfile and source directories.
- **Website deploy** from `main`.
- **Release workflow**, still gated by the human.

Pull-request-triggered test, lint and scan jobs are removed.

## 4. Optional `run-ci` label

A repo may keep one manual check workflow that runs only when a pull request has the `run-ci` label, or by `workflow_dispatch`, for a one-off run:

```yaml
on:
  pull_request:
    types: [labeled]
  workflow_dispatch:
jobs:
  check:
    if: ${{ github.event_name == 'workflow_dispatch' || github.event.label.name == 'run-ci' }}
```

## 5. Rules for the workflows that remain

1. **Timeouts.** Set `timeout-minutes` to 10 to 15 on every job.
2. **Concurrency.** Cancel superseded runs:
   ```yaml
   concurrency:
     group: ${{ github.workflow }}-${{ github.ref }}
     cancel-in-progress: true
   ```
3. **Path filters.** Build only when the Dockerfile or source changes; never on docs-only changes.
4. **Cache container builds.** Use `docker/build-push-action` with `cache-from: type=gha` and `cache-to: type=gha,mode=max`.
5. **Document it.** Record these rules in each repo's `AGENTS.md`.
