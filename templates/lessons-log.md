# Lessons log

_Each row records a candidate lesson from factory outputs. Only Mike-approved lessons feed spec prompts, patterns, and regression checks. No agent self-approves policy._

## Lessons

| ID | Source | Evidence | Class | Disposition | Approval provenance | Applied to |
|---|---|---|---|---|---|---|
| L001 | <artifact path:line> | <verbatim evidence from artifact> | dev mistake / reviewer miss / unsupported finding | validated / rejected / pending | <approval reference or "pending"> | <where applied: spec template, pattern, matrix row, or "not yet"> |

## Definitions

**Source:** The artifact and line where the lesson originated (e.g., `review-round-1.md:45`, `build-report.md:23`).

**Evidence:** Verbatim text from the source artifact that supports the lesson. Do not summarize.

**Class:**
- **dev mistake:** A recurring error made during development that could be caught earlier.
- **reviewer miss:** A defect the review panel should have caught but did not.
- **unsupported finding:** A finding that was raised but later shown to be incorrect or not applicable.

**Disposition:**
- **validated:** Mike approved; the lesson feeds spec prompts, patterns, or regression checks.
- **rejected:** Mike reviewed and declined; the lesson is not applied.
- **pending:** Awaiting Mike's review; the lesson is not applied until validated.

**Approval provenance:** Reference to Mike's approval (e.g., "Mike, 2026-11-05, Slack thread #factory-process"). Pending lessons have no provenance yet.

**Applied to:** Where the validated lesson has been incorporated:
- Spec template (`templates/spec.md`)
- Reference pattern in `templates/architect-handoff.md`
- Regression check row in a test matrix
- Not yet applied

## Rules

1. **No agent self-approves policy.** An agent may propose a lesson (disposition: pending), but only Mike can validate it.
2. **Only validated lessons are applied.** Pending and rejected lessons do not feed spec prompts, patterns, or regression checks.
3. **Evidence is verbatim.** Do not paraphrase or summarize the source evidence.
4. **Provenance is required.** A validated lesson must cite the approval reference.
