# CI minutes standard

CI minutes are a limited budget. A single hung job can run until the platform's time limit and use up a large share of a month's minutes. Every repo built by the factory follows these rules.

1. **Timeouts.** Set `timeout-minutes` to 10 to 15 on every job.
2. **Concurrency.** Cancel superseded runs:
   ```yaml
   concurrency:
     group: ${{ github.workflow }}-${{ github.ref }}
     cancel-in-progress: true
   ```
3. **Triggers.**
   - `push` only on `main` and `test`.
   - `pull_request` with types `[ready_for_review, synchronize, labeled]`, and skip drafts unless the pull request has a `run-ci` label:
     `if: ${{ !github.event.pull_request.draft || contains(github.event.pull_request.labels.*.name, 'run-ci') }}`
   - `workflow_dispatch` for manual runs.
   - No duplicate push and pull request runs for the same commit.
   - `paths-ignore` for docs-only changes (`docs/**`, `**/*.md`).
4. **Fail fast.** A quick lint job runs first. Test and end-to-end jobs declare `needs: lint`.
5. **Cache container builds.** Use `docker/build-push-action` with `cache-from: type=gha` and `cache-to: type=gha,mode=max`.
6. **Document it.** Record these rules in each repo's `AGENTS.md`.

Drafts and agent review rounds run checks locally. Mark a pull request ready for review once.
