# Lessons log

_Each row records a lesson from factory outputs. Lessons are facts about defects or reviewer misses that can be logged, analyzed, and used to clarify or test existing approved requirements. New policy or standards changes need the human's approval and are never adopted automatically._

## Lessons

| ID | Source | Evidence | Class | Type | Disposition | Approval | Applied to |
|---|---|---|---|---|---|---|---|
| L001 (Example) | `<artifact path:line>` | `<verbatim evidence, redacted>` | dev mistake / reviewer miss / unsupported finding | clarification / new-policy | proposed / accepted / rejected / applied | `<link to human's message>` or "n/a (clarification)" | `<where applied, or "not yet">` |

## Definitions

**Source:** The artifact and line where the lesson originated (e.g., `review-round-1.md:45`, `build-report.md:23`).

**Evidence:** Verbatim text from the source artifact that supports the lesson. Before recording, redact secrets, tokens, keys, `.env` values, and real personal data as `[REDACTED]`; redaction is the only allowed edit to verbatim evidence. Run gitleaks over recorded evidence before commit.

**Class:**

- **dev mistake:** A recurring error made during development that could be caught earlier.
- **reviewer miss:** A defect the four lenses should have caught but did not.
- **unsupported finding:** A finding that was raised but later shown to be incorrect or not applicable.

**Type:**

- **clarification:** Clarifies or tests an existing approved requirement. Does not require the human's approval to apply. A clarification may only add or tighten matrix rows, never remove or relax them.
- **new-policy:** Proposes a new policy, standard, or requirement. Requires the human's approval before adoption. If the type is unclear, it defaults to new-policy.

**Disposition:**

- **proposed:** Lesson has been identified but not yet reviewed.
- **accepted:** Lesson has been reviewed and accepted for application.
- **rejected:** Lesson has been reviewed and declined.
- **applied:** Lesson has been incorporated into the factory.

**Approval:** Link to the human's own message approving the lesson (e.g., "Slack #factory-process 2026-11-05"). For clarifications, write "n/a (clarification)". An agent's say-so is never approval.

**Applied to:** Where the lesson has been incorporated:

- Regression check row in a test matrix (clarification of existing requirement)
- Known pitfall in a spec (clarification of existing requirement)
- Spec template (`templates/spec.md`), new-policy only with approval
- Reference pattern in `templates/architect-handoff.md`, new-policy only with approval
- Standards document, new-policy only with approval
- Not yet applied

## Validated lesson

A validated lesson is one with:

- Disposition "accepted" or "applied", AND
- Type "clarification", OR type "new-policy" with a human approval link.

Only validated lessons may be pulled into specs as known pitfalls. See `docs/process.md` section 3a.

## Rules

1. **Clarifications apply without approval.** Lessons that clarify or test existing approved requirements (type: clarification) can be logged and applied to matrix rows, known pitfalls, and regression checks without the human approving each one. A clarification may only add or tighten matrix rows, never remove or relax them.
2. **New policy requires the human's approval.** Any lesson that proposes a new policy, standard, or requirement (type: new-policy) must have the human's explicit approval before adoption. Record the approval link. An agent's say-so is never approval.
3. **New policy is never automatic.** Agents may propose new-policy lessons, but they are never adopted automatically. Only the human can approve them.
4. **Evidence is verbatim with redaction.** Do not paraphrase or summarize the source evidence. Redact secrets, tokens, keys, `.env` values, and real personal data as `[REDACTED]` before recording.
5. **Default to new-policy.** If the type is unclear, it defaults to new-policy.
