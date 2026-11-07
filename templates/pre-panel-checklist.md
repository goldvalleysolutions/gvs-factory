# Pre-panel developer checklist

_Tick each item before launching lenses. A reviewer or PM may request evidence of completion._

## Standards and profiles

- [ ] I read the pinned `common.md` plus every profile declared in this repo's `STANDARDS.md`.

## Local verification

- [ ] I ran `scripts/verify-local.sh` on the exact head that will be reviewed (clean tree).
- [ ] `scripts/run-factory-guards.sh` ran as part of that verification and did not skip a required check.
- [ ] Required guards fail closed: missing `python3` / `jsonschema` / other required tools is FAIL.

## Provenance fixtures

- [ ] Provenance fixtures cover valid records, duplicate lens, missing lens, malformed JSON, absent overall verdict, contradictory overall verdict, and missing dependency.

## Terminology and naming

- [ ] Lens names are exactly Security, Code, Tests and evals, UX, Consistency everywhere I edited.

## Reviewer isolation

- [ ] Reviewers start from the recorded base SHA, never a branch name.
- [ ] The lens prompt does not name the PR number.

## Lens instructions

- [ ] I will paste only the matching italic lens paragraph into each launch.

## Bundle contents

- [ ] The bundle includes each STANDARDS.md reference file.
- [ ] Evidence pack is scrubbed of secrets, tokens, and personal data; screenshots checked by eye.

## Approval and citation

- [ ] Every `[APPROVED]` tag I added or edited has a resolvable source.
- [ ] Example and live deviation rows have owner, target (date or plan), and approval or `Baselined <date>`.
- [ ] Citations I added point at files that exist (no bare missing filenames).

## Cleanup

- [ ] I searched the tree for wording I replaced, so the old term is gone.

## Model provenance

- [ ] Requested model and reported model will be recorded honestly (`not reported` if the platform is silent).

## Bundle integrity

- [ ] The sanitized bundle still contains only the diff, acceptance criteria, standards plus reference files, evidence pack, and that lens's instructions — no builder commentary and no prior-review narratives.

---

## Limitations the builder should not pretend to close

- Reviewer isolation remains procedural.
- Model identity remains requested vs reported.
- Secret and PII scrubbing of screenshots is partly manual.
- Approval links cannot be proven to be Mike's own words by a script.
- Citation checks prove a path exists (and, if a line is given, that the line still looks relevant), not that the cited decision is correct.

---

_Template source: gvs-factory/templates/pre-panel-checklist.md_
