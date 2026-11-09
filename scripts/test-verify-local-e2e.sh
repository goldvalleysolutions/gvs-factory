#!/usr/bin/env bash
# Applicability regression probes for native docs-only e2e N/A in verify-local.sh.
# Stubbed npx/semgrep here prove wiring only. They are not browser evidence and
# do not replace installed gitleaks/semgrep on the factory HEAD.
# Run from the factory repo: bash scripts/test-verify-local-e2e.sh
set -u
FACTORY=$(git rev-parse --show-toplevel) || exit 2
SRC="$FACTORY/scripts/verify-local.sh"
failed=0

setup() {
  work=$(mktemp -d)
  git -C "$work" init -q
  git -C "$work" -c user.name=test -c user.email=test@example.com checkout -q -b main
  mkdir -p "$work/scripts"
  cp "$SRC" "$work/scripts/verify-local.sh"
}

commit() {
  git -C "$work" -c user.name=test -c user.email=test@example.com add -A
  git -C "$work" -c user.name=test -c user.email=test@example.com commit -q -m "t"
}

check() {
  local name=$1 needle=$2
  if printf '%s\n' "$out" | grep -F -- "$needle" >/dev/null; then
    echo "PASS $name"
  else
    echo "FAIL $name (missing: $needle)"
    echo "$out"
    failed=1
  fi
}

absent() {
  local name=$1 needle=$2
  if printf '%s\n' "$out" | grep -F -- "$needle" >/dev/null; then
    echo "FAIL $name (unexpected: $needle)"
    echo "$out"
    failed=1
  else
    echo "PASS $name"
  fi
}

echo "=== 1. eligible docs N/A ==="
setup
printf 'VERIFY_E2E_NA_REASON=no application runtime, docs-only\n' > "$work/.verify-local.env"
commit
out=$(cd "$work" && bash scripts/verify-local.sh 2>&1) || true
check "eligible N/A row" "N/A (no application runtime, docs-only)"
check "eligible overall PASS" "Overall: PASS"
absent "eligible is not echo PASS" "echo '"
absent "eligible is not SKIP N/A" "SKIP (browser e2e"
rm -rf "$work"

echo "=== 2. configured command stays applicable ==="
setup
printf 'VERIFY_E2E_CMD=true\nVERIFY_E2E_NA_REASON=should-not-apply\n' > "$work/.verify-local.env"
commit
out=$(cd "$work" && bash scripts/verify-local.sh 2>&1) || true
check "configured command ran" "| \`true\` | PASS |"
absent "configured command is not N/A" "playwright e2e"
rm -rf "$work"

echo "=== 3. suite stays applicable (stub npx, not browser evidence) ==="
setup
mkdir -p "$work/tests/e2e"
echo "placeholder" > "$work/tests/e2e/placeholder.spec.ts"
commit
bindir=$(mktemp -d)
printf '#!/bin/sh\necho stub-npx-not-browser-evidence\nexit 1\n' > "$bindir/npx"
chmod +x "$bindir/npx"
out=$(cd "$work" && PATH="$bindir:$PATH" bash scripts/verify-local.sh 2>&1) || true
check "suite invoked playwright" "npx playwright test"
absent "suite is not N/A" "N/A ("
absent "suite stub is not browser PASS" "desktop "
rm -rf "$work" "$bindir"

echo "=== 4. compose stays applicable ==="
setup
printf 'VERIFY_E2E_NA_REASON=docs-only\n' > "$work/.verify-local.env"
printf 'services: {}\n' > "$work/compose.yaml"
commit
out=$(cd "$work" && bash scripts/verify-local.sh 2>&1) || true
check "compose ineligible" "FAIL (N/A claim ineligible: application runtime, tests/e2e, or configured command)"
absent "compose is not N/A granted" "N/A (docs-only)"
rm -rf "$work"

echo "=== 5. missing rationale fails closed ==="
setup
commit
out=$(cd "$work" && bash scripts/verify-local.sh 2>&1) || true
check "missing rationale FAIL" "FAIL (no tests/e2e/ and no VERIFY_E2E_CMD; docs-only N/A requires VERIFY_E2E_NA_REASON and no application runtime)"
absent "missing rationale is not N/A" "N/A ("
rm -rf "$work"

echo "=== 6. missing scanner fails even with --allow-missing ==="
setup
printf 'VERIFY_E2E_NA_REASON=no application runtime, docs-only\n' > "$work/.verify-local.env"
commit
bin=$(mktemp -d); np=""
IFS=:
for d in $PATH; do
  if [ -x "$d/gitleaks" ]; then
    for f in "$d"/*; do
      [ -f "$f" ] && [ -x "$f" ] || continue
      b=$(basename "$f"); [ "$b" = gitleaks ] && continue
      ln -sf "$f" "$bin/$b"
    done
    continue
  fi
  np="${np:+$np:}$d"
done
unset IFS
out=$(cd "$work" && PATH="$bin:$np" bash scripts/verify-local.sh --allow-missing 2>&1) || true
check "missing gitleaks is FAIL" "FAIL (MISSING: gitleaks not installed)"
absent "missing gitleaks not skipped" "SKIP (MISSING: gitleaks"
rm -rf "$work" "$bin"

echo "=== 7. failing scanner is FAIL (stub semgrep, not a real scan) ==="
setup
printf 'VERIFY_E2E_NA_REASON=no application runtime, docs-only\n' > "$work/.verify-local.env"
commit
bindir=$(mktemp -d)
printf '#!/bin/sh\necho stub-semgrep-fail-not-a-real-scan\nexit 1\n' > "$bindir/semgrep"
chmod +x "$bindir/semgrep"
out=$(cd "$work" && PATH="$bindir:$PATH" bash scripts/verify-local.sh 2>&1) || true
check "failing semgrep is FAIL" "| \`semgrep scan --config p/ci --error\` | FAIL"
check "failing scanner overall FAIL" "Overall: FAIL"
absent "failing scanner not skipped" "SKIP (MISSING: semgrep"
rm -rf "$work" "$bindir"

if [ $failed -eq 0 ]; then
  echo "All causal e2e-applicability cases PASS"
  exit 0
fi
echo "Causal e2e-applicability cases FAIL"
exit 1
