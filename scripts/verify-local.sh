#!/usr/bin/env bash
# verify-local.sh: run all checks locally and print a Markdown "Local verification" block.
# Usage: verify-local.sh [--allow-missing] [-h]
# Env:   SEMGREP_CONFIG=p/ci (default) or auto
#        VERIFY_DIRS="frontend backend"  directories to check (default: auto-detect . and first-level subdirs)
#        VERIFY_COMPOSE_FILE=compose.yaml  compose file (default: auto-detect compose.yaml/yml, docker-compose.yaml/yml at the root)
#        VERIFY_COMPOSE_TEST="cmd"  run cmd against the stack (docker compose up -d --wait ... down -v)
#        VERIFY_E2E_CMD="cmd"  end-to-end command (e.g. npx playwright test); runs while the compose stack is up, if any
#          (COMPOSE_PROJECT_NAME and COMPOSE_FILE are exported to both, so inner `docker compose` calls hit the stack)
#        VERIFY_DOCKER_TARGET=app  build target for ./Dockerfile; VERIFY_DOCKERFILES="Dockerfile.worker"  extra Dockerfiles
#        VERIFY_DOCKER_BUILD_ARGS="--network host"  extra flags for docker build (not compose)
#        VERIFY_SKIP="mypy"  checks to skip (first word or full label); reason: VERIFY_SKIP_REASON
#        A repo may set any VERIFY_* / SEMGREP_CONFIG in .verify-local.env (KEY=VALUE lines; the environment wins)
# Exit:  non-zero if any check FAILs, a required tool is MISSING (without --allow-missing), or the tree is dirty.
set -u

ALLOW_MISSING=0
for arg in "$@"; do
  case "$arg" in
    --allow-missing) ALLOW_MISSING=1 ;;
    -h|--help) sed -n '2,14p' "$0"; exit 0 ;;
    *) echo "unknown argument: $arg" >&2; exit 2 ;;
  esac
done

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "not a git repository" >&2; exit 2; }
cd "$ROOT" || exit 2
# Repo-level settings: KEY=VALUE lines, only VERIFY_* and SEMGREP_CONFIG; never sourced.
if [ -f .verify-local.env ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in ''|'#'*) continue ;; esac
    key=${line%%=*}; val=${line#*=}
    case "$key" in VERIFY_*|SEMGREP_CONFIG) ;; *) echo "ignoring $key in .verify-local.env" >&2; continue ;; esac
    val=${val#\"}; val=${val%\"}
    [ -z "${!key+x}" ] && export "$key=$val"
  done < .verify-local.env
fi
read -r -a SKIPS <<<"${VERIFY_SKIP:-}"
SKIP_REASON=${VERIFY_SKIP_REASON:-not part of this repo\'s gate}
read -r -a BUILD_ARGS <<<"${VERIFY_DOCKER_BUILD_ARGS:-}"
LOG_DIR=$(mktemp -d "${TMPDIR:-/tmp}/verify-local.XXXXXX")
ROWS=()
FAILED=0

have() { command -v "$1" >/dev/null 2>&1; }
add_row() { ROWS+=("| \`$1\` | $2 | $3 |"); }

# run <dir> <label> <command...>
run() {
  local dir=$1 label=$2; shift 2
  local start end rc logf k
  for k in "${SKIPS[@]}"; do
    if [ "$k" = "${label%% *}" ] || [ "$k" = "$label" ]; then skip "$dir" "$label" "$SKIP_REASON"; return 0; fi
  done
  logf="$LOG_DIR/$(printf '%s' "$dir-$label" | tr -c 'A-Za-z0-9._-' '_').log"
  start=$(date +%s)
  ( cd "$dir" && "$@" ) >"$logf" 2>&1
  rc=$?
  end=$(date +%s)
  local shown=$label
  [ "$dir" != "." ] && shown="$dir: $label"
  if [ $rc -eq 0 ]; then
    add_row "$shown" PASS "$((end - start))s"
  else
    add_row "$shown" "FAIL (exit $rc, log $logf)" "$((end - start))s"
    FAILED=1
  fi
}
skip() { local shown=$2; [ "$1" != "." ] && shown="$1: $2"; add_row "$shown" "SKIP ($3)" "0s"; }
# missing <tool> [reason]
missing() {
  local why=${2:-not installed}
  if [ $ALLOW_MISSING -eq 1 ]; then
    add_row "$1" "SKIP (MISSING: $1 $why, allowed)" "0s"
  else
    add_row "$1" "FAIL (MISSING: $1 $why)" "0s"; FAILED=1
  fi
}
DOCKER_OK=
docker_ok() {
  if [ -z "$DOCKER_OK" ]; then
    if ! have docker; then DOCKER_OK=none
    elif ! docker info >/dev/null 2>&1; then DOCKER_OK=down
    else DOCKER_OK=yes; fi
  fi
  [ "$DOCKER_OK" = yes ]
}
docker_missing() {
  if [ "$DOCKER_OK" = none ]; then missing docker; else missing docker "daemon not reachable"; fi
}

has_npm_script() { (cd "$1" && node -e "const s=require(process.cwd()+'/package.json').scripts||{};process.exit(s[process.argv[1]]?0:1)" "$2") 2>/dev/null; }
pyproj_has() { grep -Eq "$2" "$1/pyproject.toml" 2>/dev/null; }

# build_scan <dir> <dockerfile relative to dir>
build_scan() {
  local d=$1 f=$2 img label
  local args=("${BUILD_ARGS[@]}")
  # VERIFY_DOCKER_TARGET applies to the primary Dockerfile only.
  [ "$f" = Dockerfile ] && [ -n "${VERIFY_DOCKER_TARGET:-}" ] && args+=(--target "$VERIFY_DOCKER_TARGET")
  if docker_ok; then
    img="verify-local-$(basename "$(cd "$d" && pwd)" | tr '[:upper:]' '[:lower:]')-$(printf '%s' "$f" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9.-' '-'):scan"
    label="docker build"; [ "$f" != Dockerfile ] && label="docker build -f $f"
    run "$d" "$label" docker build -q "${args[@]}" -f "$f" -t "$img" .
    case "${ROWS[-1]}" in
      *"| PASS |"*)
        if have trivy; then
          label="trivy image --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1"
          [ "$f" != Dockerfile ] && label="$label ($f)"
          run "$d" "$label" \
            trivy image --quiet --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 "$img"
        else missing trivy; fi ;;
      *"SKIP"*) ;;
      *) label="trivy image"; [ "$f" != Dockerfile ] && label="$label ($f)"
         skip "$d" "$label" "image did not build" ;;
    esac
  else docker_missing; fi
}

# Directories to check
if [ -n "${VERIFY_DIRS:-}" ]; then
  read -r -a DIRS <<<"$VERIFY_DIRS"
else
  DIRS=()
  for d in . */; do
    d=${d%/}
    case "$d" in node_modules|.git|.venv|venv|dist|build) continue ;; esac
    if [ -f "$d/package.json" ] || [ -f "$d/pyproject.toml" ] || [ -f "$d/requirements.txt" ] || [ -f "$d/Dockerfile" ]; then
      DIRS+=("$d")
    fi
  done
fi

# Tree state (checked before running, since installs may write lockfiles or caches)
if [ -n "$(git status --porcelain)" ]; then TREE="DIRTY (uncommitted changes; results do not match the head SHA)"; DIRTY=1; else TREE="clean"; DIRTY=0; fi

for d in "${DIRS[@]}"; do
  [ -d "$d" ] || { add_row "$d" "FAIL (directory not found)" "0s"; FAILED=1; continue; }
  if [ -f "$d/package.json" ]; then
    if have npm; then
      run "$d" "npm ci" npm ci --no-audit --no-fund
      for s in lint typecheck test test:e2e; do
        if has_npm_script "$d" "$s"; then run "$d" "npm run $s" npm run "$s"; else skip "$d" "npm run $s" "no script"; fi
      done
      run "$d" "npm audit --audit-level=high" npm audit --audit-level=high
    else missing npm; fi
  fi
  if [ -f "$d/pyproject.toml" ] || [ -f "$d/requirements.txt" ]; then
    if have ruff && { pyproj_has "$d" '\[tool\.ruff' || [ -f "$d/ruff.toml" ] || [ -f "$d/.ruff.toml" ]; }; then
      run "$d" "ruff check ." ruff check .
    else skip "$d" "ruff check ." "not configured or not installed"; fi
    if have mypy && { pyproj_has "$d" '\[tool\.mypy' || [ -f "$d/mypy.ini" ]; }; then
      run "$d" "mypy ." mypy .
    else skip "$d" "mypy ." "not configured or not installed"; fi
    if have pytest; then
      # shellcheck disable=SC2016  # expanded by the inner bash
      run "$d" "pytest -q" bash -c 'pytest -q; rc=$?; [ $rc -eq 5 ] && exit 0; exit $rc'
    else skip "$d" "pytest -q" "pytest not installed"; fi
    if have pip-audit; then
      if [ -f "$d/requirements.txt" ]; then run "$d" "pip-audit -r requirements.txt" pip-audit -r requirements.txt
      else run "$d" "pip-audit ." pip-audit .; fi
    else missing pip-audit; fi
  fi
  if [ -f "$d/Dockerfile" ]; then build_scan "$d" Dockerfile; fi
done

for f in ${VERIFY_DOCKERFILES:-}; do
  if [ -f "$f" ]; then build_scan "$(dirname "$f")" "$(basename "$f")"
  else add_row "docker build -f $f" "FAIL (file not found)" "0s"; FAILED=1; fi
done

# Containers: compose stack and end-to-end tests (opt-in through env vars)
COMPOSE_FILE_FOUND=${VERIFY_COMPOSE_FILE:-}
if [ -z "$COMPOSE_FILE_FOUND" ]; then
  for f in compose.yaml compose.yml docker-compose.yaml docker-compose.yml; do
    [ -f "$f" ] && { COMPOSE_FILE_FOUND=$f; break; }
  done
fi
STACK_UP=0
if [ -n "$COMPOSE_FILE_FOUND" ] && [ -n "${VERIFY_COMPOSE_TEST:-}${VERIFY_E2E_CMD:-}" ]; then
  if docker_ok; then
    export COMPOSE_PROJECT_NAME="verify-local-$$" COMPOSE_FILE="$COMPOSE_FILE_FOUND"
    COMPOSE=(docker compose -f "$COMPOSE_FILE" -p "$COMPOSE_PROJECT_NAME")
    run . "docker compose up -d --build --wait" "${COMPOSE[@]}" up -d --build --wait
    case "${ROWS[-1]}" in *"| PASS |"*) STACK_UP=1 ;; esac
  else docker_missing; fi
elif [ -n "$COMPOSE_FILE_FOUND" ]; then
  skip . "docker compose up" "VERIFY_COMPOSE_TEST not set"
fi
if [ -n "${VERIFY_COMPOSE_TEST:-}" ]; then
  if [ $STACK_UP -eq 1 ]; then run . "$VERIFY_COMPOSE_TEST" bash -c "$VERIFY_COMPOSE_TEST"
  else skip . "$VERIFY_COMPOSE_TEST" "compose stack not up"; fi
fi
if [ -n "${VERIFY_E2E_CMD:-}" ]; then
  if [ -n "$COMPOSE_FILE_FOUND" ] && [ $STACK_UP -eq 0 ]; then skip . "$VERIFY_E2E_CMD" "compose stack not up"
  else run . "$VERIFY_E2E_CMD" bash -c "$VERIFY_E2E_CMD"; fi
fi
if [ -n "${COMPOSE+x}" ]; then
  # Always tear down, even after a failed up or test.
  run . "docker compose down -v" "${COMPOSE[@]}" down -v --remove-orphans
fi

# Repo-wide security scans
if have gitleaks; then run . "gitleaks dir ." gitleaks dir . --redact --no-banner; else missing gitleaks; fi
# Semgrep free registry rules. p/ci works with metrics off (--config auto requires metrics on).
SEMGREP_CONFIG=${SEMGREP_CONFIG:-p/ci}
if have semgrep; then run . "semgrep scan --config $SEMGREP_CONFIG --error" semgrep scan --config "$SEMGREP_CONFIG" --error --quiet --metrics=off --disable-version-check
else missing semgrep; fi

[ $DIRTY -eq 1 ] && FAILED=1

cat <<OUT
## Local verification

- Repo: $(basename "$(git config --get remote.origin.url 2>/dev/null || echo "$ROOT")" .git)
- Branch: $(git rev-parse --abbrev-ref HEAD)
- Head SHA: $(git rev-parse HEAD)
- Tree: $TREE
- Time: $(TZ=America/New_York date '+%Y-%m-%d %H:%M') America/New_York
- Directories: ${DIRS[*]:-(none detected)}

| Command | Result | Duration |
|---|---|---|
OUT
printf '%s\n' "${ROWS[@]}"
echo
if [ $FAILED -eq 0 ]; then echo "Overall: PASS"; else echo "Overall: FAIL"; fi
exit $FAILED
