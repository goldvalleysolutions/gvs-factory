# Test matrix: <project> · <pull request or job name>

_The chief architect produces this matrix before the build starts. The Reviewer executes it independently on the exact head before the four-lens review, recording raw outputs and the environment._

**Spec:** `<path to spec.md>`
**Handoff:** `<path to architect-handoff.md>`
**Date created:** <...>
**Architect:** <name or agent>

## Matrix

| Criterion | Case | Command | Expected exit | Expected output | Executed by | Head SHA | Actual exit | Actual output |
|---|---|---|---|---|---|---|---|---|
| AC-T1.1 | positive | `<exact command>` | 0 | `<expected output or pattern>` | | | | |
| AC-T1.1 | negative | `<exact command with bad input>` | non-zero | `<expected error or rejection>` | | | | |
| AC-T1.1 | environment | `<command without required tool>` | non-zero | `<expected missing-tool error>` | | | | |
| AC-T1.2 | positive | `...` | ... | ... | | | | |
| AC-T1.2 | negative | `...` | ... | ... | | | | |
| AC-T1.2 | environment | `...` | ... | ... | | | | |
| AC-G.1 | positive | `...` | ... | ... | | | | |

_Add rows for every acceptance criterion. Each criterion gets at least one positive, one negative, and one environment case._

## Environment cases

Environment cases test behavior when:
- A required tool is missing (e.g., `python3` not on PATH)
- A dependency is not installed (e.g., missing venv, missing package)
- Configuration is absent or malformed (e.g., no `.env`, invalid JSON)
- The runtime differs from the build environment (e.g., different OS, different Python version)

## Execution record

_The Reviewer fills this section when executing the matrix independently before the four-lens review._

**Executed by:** <Reviewer name or agent>
**Head SHA:** `<exact commit hash>`
**Date and time:** <...>
**Environment:**
- OS: <...>
- Shell: <...>
- Python version: <...>
- Node version (if applicable): <...>
- Other relevant versions: <...>

**Summary:**
- Total cases: <n>
- Passed (actual matched expected): <n>
- Failed (actual did not match expected): <n>
- Blocked (could not execute): <n>

_If any case failed or was blocked, the Reviewer must record the details and the four-lens review must address them._
