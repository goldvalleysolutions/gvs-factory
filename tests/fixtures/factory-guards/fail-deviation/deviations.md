# Deviations fixture

| Owner | Paths | Rule ID | Reason | Target | Approval |
|-------|-------|---------|--------|--------|----------|
| Dev | some/path | EX-01 | Legacy code | To be migrated | |

This fixture should FAIL the deviation-fields guard because Target is just "To be migrated" without a plan, and Approval is empty.
