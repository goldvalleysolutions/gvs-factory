# Test matrix: <project>, <pull request or job name>

_The Chief architect produces this matrix before the build starts. The Reviewer executes it independently on the exact head before the four-lens review, recording raw outputs and the environment._

**Spec:** `<path to spec.md>`
**Handoff:** `<path to architect-handoff.md>`
**Date created:** <...>
**Architect:** <name or agent>

## Matrix

| Criterion | Case | Command | Expected behaviour | Executed by | Head SHA | Actual behaviour |
|---|---|---|---|---|---|---|
| AC-T1.1 | positive | `pytest tests/test_export.py::test_export_own_notes` | exit 0, test passes | | | |
| AC-T1.1 | negative | `pytest tests/test_export.py::test_export_empty` | exit 0, test passes asserting empty CSV with header only | | | |
| AC-T1.1 | environment | `d=$(mktemp -d) && echo 'import nonexistent_xyz' > "$d/test_env.py" && pytest "$d/test_env.py"` | exit non-zero, ModuleNotFoundError for nonexistent_xyz (pytest runs, import fails) | | | |
| AC-T1.2 | positive | `curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/notes/export.csv` | HTTP 401 | | | |
| AC-T1.2 | negative | `curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer invalid" http://localhost:8000/notes/export.csv` | HTTP 401 | | | |
| AC-T1.2 | environment | `curl -s -o /dev/null -w "%{http_code}" http://localhost:9999/notes/export.csv` (wrong port) | connection refused or timeout | | | |
| AC-G.1 | positive | `bash scripts/verify-local.sh --allow-missing` | exit 0, no FAIL rows | | | |
| AC-G.1 | negative | See spec.md section 4 AC-G.1/AC-G.2 scaffold | exit non-zero, FAIL row for ruff (F401 unused import) | | | |
| AC-G.1 | environment | `(gitleaks() { return 127; }; export -f gitleaks; bash scripts/verify-local.sh)` | exit non-zero, output contains "MISSING: gitleaks" row | | | |

_Add rows for every acceptance criterion. Each criterion gets at least one positive, one negative, and one environment case. State expectations as expected observable behaviour (e.g., "HTTP 401", "pytest test passes asserting rejection"), not hard-coded exit codes._

## Environment cases

Environment cases test behaviour when:

- A required tool is missing (e.g., `python3` not on PATH)
- A dependency is not installed (e.g., missing venv, missing package)
- Configuration is absent or malformed (e.g., no `.env`, invalid JSON)
- The runtime differs from the build environment (e.g., different OS, different Python version)

## Execution record

_The Reviewer fills this section when executing the matrix independently before the four-lens review. This is the single source of matrix evidence; `templates/review.md` links here._

**Executed by:** <Reviewer name or agent>
**Head SHA:** `<exact commit hash>`
**Date and time:** <...>

**Environment:**

- OS: <...>
- Shell: <...>
- Python version (if applicable): <...>
- Node version (if applicable): <...>
- Other relevant versions: <...>

**Summary:**

- Total cases: <n>
- Passed (actual matched expected): <n>
- Failed (actual did not match expected): <n>
- Blocked (could not execute): <n>

**Redaction:** Before recording, redact secrets, tokens, keys, `.env` values, and real personal data as `[REDACTED]`; redaction is the only allowed edit to verbatim evidence. Run gitleaks over recorded evidence before commit.

_A failed or blocked case is CHANGES._
