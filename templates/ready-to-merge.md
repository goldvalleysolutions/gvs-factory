# Ready to merge · <repo> PR #<n>

_The human tests hands-on, so this note is short and visual: 3 to 5 lines plus a screenshot or a quick demo. It never merges anything to `main`._

**<What it is, one line.>** <pull request link>
**Try it:** <one command or link that shows the change> · <screenshot(s) or a 30 to 60 second demo>
**Checks:** head `<sha7>` merged to `test` · Local verification all PASS (on this exact head) · review round <n>: Security / Code / Tests / UX all PASS (<review link>)
**Look at:** <0 to 2 always-flagged items, one line each, or "nothing special">

Example:

**notes-app: export notes as CSV.** https://example.com/notes-app/pull/12
**Try it:** sign in as `demo@example.com`, open `/notes`, click "Export CSV" · screenshot attached
**Checks:** head `a1b2c3d` merged to `test` · Local verification PASS on this head · round 2: all four lenses PASS
**Look at:** nothing special

---
Rules:
- Cite only reviewer or Local verification evidence, never the builder's self-report.
- The Local verification block must be on the exact head. No stacked pull requests.
- Log, outside this note: agent hours, coding-agent runs and model per role, and the human's review time.
- Detail (AC tables, commands) stays in the review on the pull request. Link it; do not paste it here.
