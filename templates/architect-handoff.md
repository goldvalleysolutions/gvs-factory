# Architect handoff: <project>, <pull request or job name>

_This is a lightweight handoff document, not a review. The Chief architect produces this after the PM spec is approved and before the build starts._

**Spec:** `<path to spec.md>`
**Base branch:** `test`
**Date:** <...>
**Architect:** <name or agent>

## 1. Pinned standards and profiles

| Standard | Version | Profile (if any) |
|---|---|---|
| `standards/definition-of-done.md` | `<commit sha or tag>` | |

_Pin the exact standards version and any profiles that apply to this build. The builder and reviewers use these versions, not later ones._

## 2. Reference patterns

_Select existing patterns from the codebase that the builder must follow. Cite real paths and functions._

| Pattern | Location | Why it applies |
|---|---|---|
| <pattern name> | `<path:line or function>` | <reason> |

## 3. Requirements (verbatim from spec)

_Copy the acceptance criteria from the spec exactly as written. Do not reword or summarize._

**Task T1:**

- AC-T1.1: <verbatim>
- AC-T1.2: <verbatim>

**Whole-PR criteria:**

- AC-G.1: <verbatim>

## 4. Test matrix

_Link to the test matrix produced for this handoff. The matrix must be completed before the build starts._

**Matrix file:** `<path to test-matrix.md>`

Each acceptance criterion in the matrix has:

- Positive case: expected success with valid input
- Negative case: expected failure or rejection with invalid input
- Environment case: behaviour with missing tools, uninstalled dependencies, or non-standard environment

Each case has an exact command and expected observable behaviour, written before the build.

## 5. Known pitfalls

_Pull in validated lessons from `templates/lessons-log.md` that apply to this work. A validated lesson has disposition "accepted" or "applied" and either type "clarification" or type "new-policy" with a human approval link. List the lesson ID and how it applies._

| Lesson ID | Summary | How it applies here |
|---|---|---|
| | | |

_If no validated lessons apply, write "None applicable."_

## 6. Not a review

This handoff is preparation, not approval. The Chief architect does not approve the build. The four lenses (Security, Code, Tests and evals, UX/Consistency) run independently after the build, on the exact head. Lenses receive the sanitized bundle (see `docs/process.md` section 5a), which includes the executed matrix results but not this handoff document or the builder's narrative.
