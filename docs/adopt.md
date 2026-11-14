# Adopting the software factory

This file is the entry point for other Gold Valley repos. **Do not copy** process, templates, or standards into those repos. Point here. Future factory updates happen in `gvs-factory`; consuming `AGENTS.md` files stay as pointers.

## Pin factory `main` for one task

At the start of a task, pin goldvalleysolutions/gvs-factory `main` once for **both** the software-factory process and the shared standards (architecture, packaging, brand and style). Resolve `main` once:

```
git ls-remote https://github.com/goldvalleysolutions/gvs-factory.git refs/heads/main
```

Record the SHA. `git ls-remote` returns a foreign SHA, not an object in the consuming repo, so `git show <sha>:...` will not work there and is not required. Read factory docs at immutable GitHub URLs for that SHA (or an authenticated remote file tool). Do not clone factory into the consumer and do not copy standards. Example URLs (replace `<sha>` with the recorded SHA):

```
https://github.com/goldvalleysolutions/gvs-factory/blob/<sha>/docs/adopt.md
https://github.com/goldvalleysolutions/gvs-factory/blob/<sha>/docs/process.md
https://github.com/goldvalleysolutions/gvs-factory/blob/<sha>/standards/definition-of-done.md
https://github.com/goldvalleysolutions/gvs-factory/blob/<sha>/standards/bot-architecture.md
https://github.com/goldvalleysolutions/gvs-factory/blob/<sha>/standards/readme-template.md
https://github.com/goldvalleysolutions/gvs-factory/blob/<sha>/standards/brand-and-style.md
```

Do not move to a newer `main` mid-task. The next task resolves `main` again and gets the latest automatically. Do not add a repo-level standards pin, deviations file, or version pin beyond factory `main` at task start.

If `gvs-factory` is missing, private, or unreadable at that SHA, **FAIL explicitly**. Do not skip spec, architect handoff, test matrix, local verification, four lenses, or the 3-round cap.

This adoption task recorded factory `main` at start as `23818d44f0646bd2d2a61a3f6cd19810834fa5a4`. That pin applies to this task only.

There is no auto-updater, service, or worktree product.

## What to follow (read at the pinned SHA)

1. Spec: `templates/spec.md`
2. Chief architect handoff and test matrix: `templates/architect-handoff.md`, `templates/test-matrix.md`
3. Build and open a pull request into `test`: `templates/build-report.md`
4. Independent local verification on the exact head: `scripts/verify-local.sh`
5. Four lenses: Security, Code, Tests and evals, UX/Consistency: `templates/review.md`
6. At most 3 review rounds, then the human. Agents must not start round 4.
7. Only the human merges `test` into `main`.
8. Shared standards when the task touches bots, brand, diagrams, or site/blog copy: `standards/bot-architecture.md`, `standards/readme-template.md`, `standards/brand-and-style.md`

Full text: the GitHub blob URLs above for `docs/process.md`, `standards/definition-of-done.md`, and the shared standards files at the pinned SHA.

Advisory arbiter handles disputed findings only and has no override. Do not add extra review machinery.

Keep project-specific security instructions and check commands in the consuming repo.

## Snippet for a consuming `AGENTS.md`

```
## Software factory

Do not copy factory process or shared standards into this repo.
At task start, pin goldvalleysolutions/gvs-factory `main`
(https://github.com/goldvalleysolutions/gvs-factory/blob/main/docs/adopt.md)
for process and shared standards.
If factory source is missing or unreadable, FAIL. Do not skip factory gates.
```
