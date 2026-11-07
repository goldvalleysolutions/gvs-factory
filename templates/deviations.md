# DEVIATIONS.md template

_Copy this to a project repo as `DEVIATIONS.md`. Use it to register approved deviations from the pinned standards._

# Deviations register

This file tracks approved deviations from the standards pinned in `STANDARDS.md`. A deviation entry:

- **Prevents new drift** — Lens 5 will not fail existing baselined paths for the registered rule.
- **Is NOT a permanent waiver** — Each entry has a target and owner for resolution.
- **Requires approval** — New deviations need Mike's approval reference before merge.

## Active deviations

| Owner | Paths | Rule ID | Reason | Target | Approval |
|-------|-------|---------|--------|--------|----------|
| <name> | <file paths or patterns> | <e.g., BL-05> | <why this deviates> | <date or plan> | <Mike's approval reference> |
| | | | | | |

### Example entry

| Owner | Paths | Rule ID | Reason | Target | Approval |
|-------|-------|---------|--------|--------|----------|
| Dev | thoughts/agent-vs-api-call | BL-05 | Legacy article.njk template | Q1 2027 migration | Baselined Nov 2026, migration planned |

## Closed deviations

_Move entries here when the deviation is resolved._

| Owner | Paths | Rule ID | Resolution | Closed |
|-------|-------|---------|------------|--------|
| | | | | |

## Rules

1. **Every deviation needs an entry before merge.** Lens 5 will fail unregistered deviations.
2. **Owner is required.** Someone is responsible for the deviation.
3. **Target is required.** Either a date or a plan (e.g., "next refactor", "when template is deprecated").
4. **Approval reference is required.** New deviations cite Mike's approval. Baseline entries from the initial pin note "Baselined <date>".
5. **Baselines are not waivers.** They prevent new drift and track debt.
6. **Paths must be specific.** Use exact file paths or patterns (e.g., `thoughts/*.md`), not "various files".

## How to get Mike's approval

1. **Send the request** to Dev · Product Manager.
2. **The PM puts a card** in the HQ "Needs Mike" list on Trello with the rule ID, paths, reason, and proposed target.
3. **Wait for Mike's reply.** The approval reference is a link to Mike's own reply on that card.
4. **No fallback.** If Mike hasn't answered, the deviation is not approved, and the PR does not merge on that rule. Do not assume silence is approval.

## Adding a deviation

1. Identify the rule ID being deviated from (check STANDARDS.md profiles).
2. Get Mike's approval using the process above.
3. Add an entry with all required fields, including the link to Mike's reply.
4. Open a PR to update this file.

## Reviewing deviations

1. Check each entry still applies (paths exist, reason still valid).
2. Update targets that have passed.
3. Move resolved deviations to the Closed section.
4. Review during standards version pin updates.

---

_Template source: gvs-factory/templates/deviations.md_
