#!/usr/bin/env bash
# Causal cases for native docs-only e2e N/A in verify-local.sh.
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
rm -rf "$work"

echo "=== 2. configured command stays applicable ==="
setup
printf 'VERIFY_E2E_CMD=true\nVERIFY_E2E_NA_REASON=should-not-apply\n' > "$work/.verify-local.env"
commit
out=$(cd "$work" && bash scripts/verify-local.sh 2>&1) || true
check "configured command ran" "| \`true\` | PASS |"
absent "configured command is not N/A" "playwright e2e"
rm -rf "$work"

echo "=== 3. suite stays applicable ==="
setup
mkdir -p "$work/tests/e2e"
echo "placeholder" > "$work/tests/e2e/placeholder.spec.ts"
commit
bindir=$(mktemp -d)
printf '#!/bin/sh\necho fake-npx\nexit 1\n' > "$bindir/npx"
chmod +x "$bindir/npx"
out=$(cd "$work" && PATH="$bindir:$PATH" bash scripts/verify-local.sh 2>&1) || true
check "suite invoked playwright" "npx playwright test"
absent "suite is not N/A" "N/A ("
rm -rf "$work" "$bindir"

echo "=== 4. ambiguous N/A claim fails ==="
setup
printf 'VERIFY_E2E_NA_REASON=docs-only\n' > "$work/.verify-local.env"
echo "FROM scratch" > "$work/Dockerfile"
commit
out=$(cd "$work" && bash scripts/verify-local.sh --allow-missing 2>&1) || true
check "ambiguous ineligible" "FAIL (N/A claim ineligible: application runtime, tests/e2e, or configured command)"
absent "ambiguous is not N/A granted" "N/A (docs-only)"
rm -rf "$work"

echo "=== 5. missing scanner fails even with --allow-missing ==="
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

if [ $failed -eq 0 ]; then
  echo "All causal e2e-applicability cases PASS"
  exit 0
fi
echo "Causal e2e-applicability cases FAIL"
exit 1
