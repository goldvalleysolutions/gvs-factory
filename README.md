# Gold Valley Solutions Software Factory

This repo holds the software factory: the way Gold Valley Solutions turns ideas into working software with a team of AI agents and one human approver.

## What it is

The factory is an agent-driven software development process. Every change moves through the same steps:

1. **Request.** An idea comes in and gets ranked.
2. **Spec.** A product manager agent writes a build spec. Each acceptance criterion has a "Verify" line that says how to check it.
3. **Approval gate.** A human approves the spec before any build starts.
4. **Build.** A developer agent builds the change on a branch, opens a pull request, and writes a build report.
5. **Review.** One review pass covers four lenses: security, code, tests and evals, and UX. Each lens returns PASS or CHANGES. Any CHANGES sends the work back to build, up to three rounds.
6. **Merge readiness.** A short note spot-checks the evidence and lists anything the human must decide.
7. **Merge.** Only the human merges to `main`. Nothing auto-merges.

Money, auth and permissions, deploys, database changes, sending email, new dependencies, and business decisions are always flagged for the human.

## What is in this repo

- `standards/`: shared engineering and packaging standards.
- `software-factory/`: the original review and plan, the pilot spec, reviews and retro, specs, templates, visuals, and a full description of the process.
- `software-factory/templates/`: the spec, build report, review, and ready-to-merge templates.
- `plans/`: supporting standards such as the CI minutes standard.

Some documents use placeholders such as `<workspace>/` or `<build-host>` where internal details were removed.

## Credits

The process was inspired by public discussion of AI software factories, including a demo by ZazenCodes. Gold Valley Solutions took the ideas, not the files. All documents here are original Gold Valley Solutions work.

## License

Apache License 2.0. See `LICENSE` and `NOTICE`.
