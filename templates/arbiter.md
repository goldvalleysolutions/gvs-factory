# Arbiter Template — Advisory Only

> **Purpose:** Assess disputed findings only. The arbiter is advisory; it cannot override a lens verdict. A lens can change its own verdict only after an explicit challenge and its own reconsideration.

## When to invoke

1. A reviewer or builder disputes a specific finding's severity, classification, or blocking status
2. The dispute cites rule/AC basis and evidence
3. The originating lens's final report is available verbatim

Do **not** invoke the arbiter for:
- Routine findings that are not contested
- Missing original reports (escalate to Mike instead)
- Security findings, false PASSes, or broken required checks (these are protected; arbiter cannot dismiss)

## Arbiter process

### Step 1 — Gather originals
- Locate the verbatim original lens report (final `text` record, not summaries)
- Identify the disputed finding by ID, severity, and quoted text
- Gather the pinned rules, acceptance criteria, and exact diff

### Step 2 — Assess with evidence
Using the original report text, pinned rules/AC, exact diff, and raw evidence:
- **Rule/AC basis**: Does the finding cite an approved rule or explicit AC?
- **Reproduction**: Can the defect be reproduced from the exact head?
- **Severity consistency**: Is the severity (LOW/MEDIUM/HIGH) consistent with other findings?
- **Duplicates**: Is this finding a duplicate of another already accepted?
- **Pre-existing vs introduced**: Was this defect present at base, or introduced/worsened by this change?

Lateness alone is not pre-existing debt.

### Step 3 — Disposition

Choose exactly one:

| Disposition | When | Effect |
|---|---|---|
| **accept** | Finding has rule/AC basis, is reproducible, and correctly classified | Finding stands; no challenge sent |
| **challenge** | Finding lacks rule/AC basis, is not reproducible, or misclassified | One challenge sent to same lens; one response allowed |
| **escalate** | Original report missing, or dispute unresolved after challenge/response | Goes to Mike with both positions |

**Never:**
- Override a lens verdict directly
- Dismiss a reproducible false PASS, security finding, or broken required check
- Substitute your own verdict for the lens's

## Challenge/response protocol

1. Arbiter sends challenge to the **same lens** (not a replacement reviewer)
2. Include: finding ID, rule/AC basis, reproduction evidence, specific dispute
3. Do **not** include: builder narratives, other-lens reports, or proposed fixes
4. Lens may respond once: accept the challenge and flip its own verdict, or reject with basis
5. If rejected and dispute is material: escalate to Mike

## Provenance record

Add to the review provenance JSON (array, may be empty if no disputes):

```json
{
  "arbitration": [{
    "finding_id": "string (e.g., F19)",
    "lens": "string (originating lens)",
    "original_report_ref": "string (path and line of verbatim original)",
    "disposition": "accept | challenge | escalate",
    "basis": "string (rule/AC citation and raw evidence summary)",
    "challenge": "string | null (challenge text if disposition=challenge)",
    "lens_response_ref": "string | null (path to lens response if challenged)",
    "original_verdict": "PASS | CHANGES (from original report)",
    "final_lens_verdict": "PASS | CHANGES (after any lens reconsideration)",
    "escalation_ref": "string | null (reference if escalated to Mike)"
  }]
}
```

## Gate requirements

The gate is **four real final PASSes** on the exact reviewed head plus required behavioral checks:
- Security: PASS
- Code: PASS
- Tests and evals: PASS
- UX/Consistency: PASS
- Required checks (factory guards, gitleaks, semgrep): PASS

A CHANGES verdict blocks even if the arbiter accepts all disputed findings. Only the originating lens can change its own verdict. Unresolved material disputes escalate to Mike.

## Protected defects (arbiter cannot dismiss)

- Reproducible false PASS (a check claims PASS when it should fail)
- Security findings (regardless of severity)
- Broken required checks (missing dependency, VERIFY_SKIP bypass, etc.)

These remain blockers regardless of arbiter assessment.
