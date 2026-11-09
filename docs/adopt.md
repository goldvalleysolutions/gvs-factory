# Adopting the software factory

This file is the entry point for other Gold Valley repos. **Do not copy** process, templates, or standards into those repos. Point here. Future factory updates happen in `gvs-factory`; consuming `AGENTS.md` files stay as pointers.

## Pin factory `main` for one task

At the start of a task, resolve `main` once:

```
git ls-remote https://github.com/goldvalleysolutions/gvs-factory.git refs/heads/main
```

Record the SHA. Use only that SHA for the rest of the task, for example `git show <sha>:docs/process.md`. Do not move to a newer `main` mid-task. The next task resolves `main` again and gets the latest automatically.

If `gvs-factory` is missing, private, or unreadable at that SHA, **FAIL explicitly**. Do not skip spec, architect handoff, test matrix, local verification, four lenses, or the 3-round cap.

This adoption task recorded factory `main` at start as `23818d44f0646bd2d2a61a3f6cd19810834fa5a4`. That pin applies to this task only.

There is no auto-updater, service, or worktree product.

## What to follow (read at the pinned SHA)

1. Spec — `templates/spec.md`
2. Chief architect handoff and test matrix — `templates/architect-handoff.md`, `templates/test-matrix.md`
3. Build and open a pull request into `test` — `templates/build-report.md`
4. Independent local verification on the exact head — `scripts/verify-local.sh`
5. Four lenses: Security, Code, Tests and evals, UX/Consistency — `templates/review.md`
6. At most 3 review rounds, then the human. Agents must not start round 4.
7. Only the human merges `test` into `main`.

Full text: `docs/process.md` and `standards/definition-of-done.md` at the pinned SHA.

Advisory arbiter handles disputed findings only and has no override. Do not add extra review machinery.

Keep project-specific security instructions and check commands in the consuming repo.

## Snippet for a consuming `AGENTS.md`

```
## Software factory

Do not copy factory process into this repo.
At task start, pin goldvalleysolutions/gvs-factory `main` (see docs/adopt.md).
If factory source is missing or unreadable, FAIL. Do not skip factory gates.
```
