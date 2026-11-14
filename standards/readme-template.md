<!--
Gold Valley Bots: standard README template (Mike, Nov 1 2026).
Every bot repo has this as its root README.md. The same file is synced to the
Docker Hub repo description by .github/workflows/dockerhub-description.yml
(peter-evans/dockerhub-description, readme-filepath ./README.md; runs when README.md
changes on main, or by workflow_dispatch), so:
  - use absolute https links for anything outside the README (relative links break on Docker Hub);
  - keep it plain and short; no pricing, cost tables or phone numbers;
  - every command, env var and path must exist in the repo (check before you commit).
Bots are FROM Core (gvs-core-bot) per factory standards/bot-architecture.md.
Replace <angle-bracket> placeholders and delete this comment.
-->
# <Bot Name>

<One-line tagline: what it does for whom.>

## What it is

<2-4 sentences: the job it does, what it will and will not do, and that it is one
Docker image built `FROM` Gold Valley Bot Core (`goldvalleysolutions/core-bot:<X.Y>`).>

## Quick start

Only Docker is needed (Docker Desktop, Colima or Linux; amd64 or arm64):

```bash
docker pull goldvalleysolutions/<slug>-bot:<X.Y>
docker run -d --name <slug> -p 8080:8080 -v <slug>-data:/data goldvalleysolutions/<slug>-bot:<X.Y>
```

Open <http://localhost:8080> and complete setup (`/setup`: bot-admin password, who can
use the bot, AI model, self-test). `curl -f http://localhost:8080/health` works before
and after setup. If host port 8080 is taken, change the left side, e.g. `-p 8081:8080`.

## Configuration

| Item | Value | Notes |
|---|---|---|
| Port | `8080` (container) | Map with `-p <host>:8080` |
| Volume | `/data` | `bot.db` + `bot.key`; back up both; delete the volume to start over |
| `<ENV_VAR>` | optional | <what it does, default> |

Keys and credentials are entered on `/setup` or in **Admin**, stored encrypted in `/data`.

## Repo contents

| Path | What is in it |
|---|---|
| `bot/` | The bot pack copied onto Core: `bot.yaml`, `role.md`, `skills/`, `tools/`, `theme.yaml`, `Dockerfile` |
| `scripts/` | `verify-local.sh` and helper scripts |
| `tests/` | Unit and Playwright e2e tests |
| `.github/workflows/` | Main-only Docker Hub publish; `dockerhub-description.yml` (Docker Hub overview from this README) |

## Build and test from source

```bash
git clone https://github.com/goldvalleysolutions/gvs-<slug>-bot.git
cd gvs-<slug>-bot
docker build -f bot/Dockerfile -t goldvalleysolutions/<slug>-bot:<X.Y.Z> .
scripts/verify-local.sh          # all local checks; prints the Local verification block for the PR
```

<List the real test commands: e.g. `python -m pytest tests/unit`, `make test`.>

## Versioning and releases

PRs go to `test`; only Mike merges `test` into `main`. A merge to `main` publishes
`goldvalleysolutions/<slug>-bot` as `X.Y.Z` and `X.Y` (never `latest`), creates GitHub
release `vX.Y.Z`. A README change merged to `main` updates this Docker Hub description. The version comes from
`<VERSION file or bot/bot.yaml version:>`.

Architecture reference: https://github.com/goldvalleysolutions/gvs-factory/blob/main/standards/bot-architecture.md
(use absolute https links; pin a SHA when following factory `docs/adopt.md`).

## License

Apache License 2.0. See [LICENSE](https://github.com/goldvalleysolutions/gvs-<slug>-bot/blob/main/LICENSE).
