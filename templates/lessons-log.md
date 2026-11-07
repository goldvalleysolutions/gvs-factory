# Lessons log

_Each row records a lesson from factory outputs. Lessons are facts about defects or reviewer misses that can be logged, analyzed, and used to clarify or test existing approved requirements. New policy or standards changes need Mike's approval and are never adopted automatically._

## Lessons

| ID | Source | Evidence | Class | Type | Applied to |
|---|---|---|---|---|---|
| L001 | <artifact path:line> | <verbatim evidence from artifact> | dev mistake / reviewer miss / unsupported finding | clarification / new-policy | <where applied, or "not yet"> |

## Definitions

**Source:** The artifact and line where the lesson originated (e.g., `review-round-1.md:45`, `build-report.md:23`).

**Evidence:** Verbatim text from the source artifact that supports the lesson. Do not summarize.

**Class:**
- **dev mistake:** A recurring error made during development that could be caught earlier.
- **reviewer miss:** A defect the review panel should have caught but did not.
- **unsupported finding:** A finding that was raised but later shown to be incorrect or not applicable.

**Type:**
- **clarification:** Clarifies or tests an existing approved requirement. Does not require Mike's approval to apply.
- **new-policy:** Proposes a new policy, standard, or requirement. Requires Mike's approval before adoption.

**Applied to:** Where the lesson has been incorporated:
- Regression check row in a test matrix (clarification of existing requirement)
- Known pitfall in a spec (clarification of existing requirement)
- Spec template (`templates/spec.md`) — new-policy only with approval
- Reference pattern in `templates/architect-handoff.md` — new-policy only with approval
- Standards document — new-policy only with approval
- Not yet applied

## Rules

1. **Clarifications apply without approval.** Lessons that clarify or test existing approved requirements (class: dev mistake, reviewer miss, or unsupported finding; type: clarification) can be logged and applied to matrix rows, known pitfalls, and regression checks without Mike approving each one.
2. **New policy requires Mike's approval.** Any lesson that proposes a new policy, standard, or requirement (type: new-policy) must have Mike's explicit approval before adoption. Record the approval reference (e.g., "Mike, 2026-11-05, Slack thread #factory-process").
3. **New policy is never automatic.** Agents may propose new-policy lessons, but they are never adopted automatically. Only Mike can approve them.
4. **Evidence is verbatim.** Do not paraphrase or summarize the source evidence.
