#!/usr/bin/env bash
# verify-local.sh: run all checks locally and print a Markdown "Local verification" block.
# Usage: verify-local.sh [--allow-missing] [-h]
# Env:   SEMGREP_CONFIG=p/ci (default) or auto
#        VERIFY_DIRS="frontend backend"  directories to check (default: auto-detect . and first-level subdirs)
# Exit:  non-zero if any check FAILs, a required tool is MISSING (without --allow-missing), or the tree is dirty.
set -u

ALLOW_MISSING=0
for arg in "$@"; do
  case "$arg" in
    --allow-missing) ALLOW_MISSING=1 ;;
    -h|--help) sed -n '2,5p' "$0"; exit 0 ;;
    *) echo "unknown argument: $arg" >&2; exit 2 ;;
  esac
done

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "not a git repository" >&2; exit 2; }
cd "$ROOT" || exit 2
LOG_DIR=$(mktemp -d "${TMPDIR:-/tmp}/verify-local.XXXXXX")
ROWS=()
FAILED=0

have() { command -v "$1" >/dev/null 2>&1; }
add_row() { ROWS+=("| \`$1\` | $2 | $3 |"); }

# run <dir> <label> <command...>
run() {
  local dir=$1 label=$2; shift 2
  local start end rc logf
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
missing() {
  if [ $ALLOW_MISSING -eq 1 ]; then
    add_row "$1" "SKIP (MISSING: $1 not installed, allowed)" "0s"
  else
    add_row "$1" "FAIL (MISSING: $1 not installed)" "0s"; FAILED=1
  fi
}

has_npm_script() { (cd "$1" && node -e "const s=require(process.cwd()+'/package.json').scripts||{};process.exit(s[process.argv[1]]?0:1)" "$2") 2>/dev/null; }
pyproj_has() { grep -Eq "$2" "$1/pyproject.toml" 2>/dev/null; }

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
  if [ -f "$d/Dockerfile" ]; then
    if have docker && have trivy && docker info >/dev/null 2>&1; then
      img="verify-local-$(basename "$(cd "$d" && pwd)" | tr '[:upper:]' '[:lower:]'):scan"
      run "$d" "docker build" docker build -q -t "$img" .
      run "$d" "trivy image --severity HIGH,CRITICAL --exit-code 1" trivy image --quiet --severity HIGH,CRITICAL --exit-code 1 "$img"
    else
      skip "$d" "trivy image" "docker or trivy not available"
    fi
  fi
done

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
