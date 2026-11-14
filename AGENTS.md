# gvs-factory

This repo is process, templates, and generic standards. It has no application runtime, browser UI, or `tests/e2e/` suite.

## Checks

From a clean tree at the commit to merge:

```
bash scripts/verify-local.sh
```

`--allow-missing` is local debug only. It is not merge acceptance. Gitleaks and Semgrep must be installed, execute, and pass.

## Pointers (do not duplicate)

- Process: `docs/process.md`
- Definition of done: `standards/definition-of-done.md`
- Bot architecture and Core packaging: `standards/bot-architecture.md`
- Bot README template: `standards/readme-template.md`
- Brand, diagrams, site/blog: `standards/brand-and-style.md`
- Local verification: `standards/ci-minutes.md`, `scripts/verify-local.sh`
- Native docs-only browser e2e N/A: `VERIFY_E2E_NA_REASON` in `.verify-local.env`, eligibility in `scripts/verify-local.sh`
- Consuming repos: `docs/adopt.md` (pin factory `main` at task start for process and shared standards; do not copy)
