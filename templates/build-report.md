STATUS: READY

<!-- The FIRST LINE is the verdict and must be exactly `STATUS: READY` or `STATUS: BLOCKED`. Nothing else on that line.
This report lives at the top of the pull request description. Rewrite it at the end of every round and keep the Log.
The report is a list of claims. Reviewers and CI provide the evidence that counts. -->

# Build report: <spec title>

**Spec:** <path or link to the spec> · **Base:** <branch @ short sha> · **Head:** <short sha> · **Round:** <1 | 2 | 3>

## Summary
<What the branch does now, in a few lines.>

Files changed:
- `<path>`: <one line on why>

## Acceptance criteria
<!-- One block per AC in the spec, same IDs, same order. Paste the real command and the real output (trimmed to the lines that prove it).
"Should work", "tests pass" or a ticked box with no output is not evidence. If you could not run a check, mark it NOT RUN with the reason. -->

### AC-T1.1 · <criterion as written in the spec>
- **Command:** `<exact command>`
- **Output:**
  ```
  <relevant output lines>
  ```
- **Result:** PASS | FAIL | NOT RUN (<reason>)

### AC-G.1 · CI green
- **Command:** CI checks on <head sha>
- **Output:** `Lint: success · Test: success (<n> passed)`
- **Result:** PASS | FAIL

## Validation
| Command (from AGENTS.md) | Result |
|---|---|
| `<lint command>` | pass / fail |
| `<format check command>` | pass / fail |
| `<test command>` | pass / fail (<n> passed) |

## Always-flagged items
<!-- List every always-flagged item this branch touches, with the file and one line on why. "None" only if truly none. -->
- <flag>: `<path>`: <why>

## Assumptions made while building
- <anything decided that the spec did not settle; mark [product decision → human] where it applies>

## Log
### Round 1
<What you did.>
### Round 2
<Each review finding with VERDICT: CHANGES, and what you did about it or why you did not change anything.>

<!-- If BLOCKED: first line `STATUS: BLOCKED`, then a `## Blocked` section that says exactly what blocks you (spec contradiction, a decision only the human can make, or an environment failure) and what you need. Never paper over a failure to reach READY. -->
