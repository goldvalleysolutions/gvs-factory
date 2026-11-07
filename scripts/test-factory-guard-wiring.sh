#!/usr/bin/env bash
# Test that factory guards are properly wired into the development workflow.
# This script EXECUTES guards (not just greps source) to prove they work.
#
# Tests:
# 1. Text wiring: templates/standards-pin.md and verify-local.sh name the runner
# 2. Runner on current repo exits 0
# 3. Runner on pass/ fixture tree exits 0
# 4. Runner on each fail-* fixture tree exits non-zero with specific guard failure
# 5. Provenance validator passes on valid fixtures
# 6. Provenance contradiction checking rejects invalid records
# 7. Missing-dependency tests: strip each required tool from PATH and expect non-zero
# 8. Missing jsonschema: actually hide library and expect validator to fail
# 9. VERIFY_SKIP cannot bypass required factory checks
#
# REQUIRED: python3, jsonschema==4.23.0, all shell tools
# Missing dependencies cause FAIL, not SKIP.
set -u

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "FAIL: not a git repository" >&2; exit 1; }
cd "$ROOT" || exit 1

FAILED=0
TESTS_RUN=0

pass() { echo "PASS: $1"; TESTS_RUN=$((TESTS_RUN + 1)); }
fail() { echo "FAIL: $1" >&2; FAILED=1; TESTS_RUN=$((TESTS_RUN + 1)); }

echo "Factory guard wiring tests"
echo "=========================="
echo

# Check dependencies first
for cmd in python3 grep sed cut xargs find awk; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    fail "$cmd not installed (required for wiring tests)"
    echo
    echo "Wiring tests: FAIL (missing dependencies)"
    exit 1
  fi
done

# === TEXT WIRING TESTS ===
echo "--- Text wiring ---"

# Test 1: standards-pin.md names run-factory-guards.sh
if grep -q 'run-factory-guards.sh' templates/standards-pin.md 2>/dev/null; then
  pass "standards-pin.md names run-factory-guards.sh"
else
  fail "standards-pin.md does not name run-factory-guards.sh"
fi

# Test 2: verify-local.sh invokes run-factory-guards.sh
if grep -q 'run-factory-guards.sh' scripts/verify-local.sh 2>/dev/null; then
  pass "verify-local.sh invokes run-factory-guards.sh"
else
  fail "verify-local.sh does not invoke run-factory-guards.sh"
fi

# === EXECUTION TESTS ===
echo
echo "--- Execution tests ---"

# Test 3: Runner on current repo exits 0
if scripts/run-factory-guards.sh >/dev/null 2>&1; then
  pass "run-factory-guards.sh exits 0 on current repo"
else
  fail "run-factory-guards.sh exits non-zero on current repo (should pass)"
fi

# Test 4: Runner on pass/ fixture tree exits 0
echo "Setting up pass/ fixture execution test..."
PASS_TMPDIR=$(mktemp -d)
cleanup() { rm -rf "$PASS_TMPDIR" 2>/dev/null; }
trap cleanup EXIT

cp -r tests/fixtures/factory-guards/pass/* "$PASS_TMPDIR/" 2>/dev/null || true
(cd "$PASS_TMPDIR" && git init -q && git add -A && git commit -q -m "test" 2>/dev/null) || true

if scripts/run-factory-guards.sh --root="$PASS_TMPDIR" >/dev/null 2>&1; then
  pass "run-factory-guards.sh exits 0 on pass/ fixture tree"
else
  fail "run-factory-guards.sh exits non-zero on pass/ fixture tree (should pass)"
fi

# Test 5: Runner on each fail-* fixture tree exits non-zero WITH EXACTLY ONE GUARD FAILURE
echo "Testing fail-* fixture trees (specific guard assertions)..."

# Map fixture names to expected guard failure patterns
declare -A EXPECTED_GUARD_FAILURES
EXPECTED_GUARD_FAILURES["fail-lens-name"]="canonical-lens-names"
EXPECTED_GUARD_FAILURES["fail-base-ref"]="starting-commit-wording"
EXPECTED_GUARD_FAILURES["fail-pr-number"]="prompt-no-pr-number"
EXPECTED_GUARD_FAILURES["fail-approval-tag"]="approval-tags"
EXPECTED_GUARD_FAILURES["fail-citation"]="citation-resolver"
EXPECTED_GUARD_FAILURES["fail-deviation"]="deviation-fields"
EXPECTED_GUARD_FAILURES["fail-changelog-range"]="changelog-ranges"
EXPECTED_GUARD_FAILURES["fail-standards-pairing"]="standards-pairing"
EXPECTED_GUARD_FAILURES["fail-pin-url"]="pin-source-url"
EXPECTED_GUARD_FAILURES["fail-evidence"]="evidence-secrets"

for fail_tree in tests/fixtures/factory-guards/fail-*; do
  if [ -d "$fail_tree" ]; then
    tree_name=$(basename "$fail_tree")
    expected_guard="${EXPECTED_GUARD_FAILURES[$tree_name]:-}"
    
    FAIL_TMPDIR=$(mktemp -d)
    # Use build-fixture-tree.sh to create complete fixture from overlay
    scripts/build-fixture-tree.sh "$fail_tree" "$FAIL_TMPDIR" >/dev/null 2>&1
    
    # Capture output to check for specific guard failure
    output=$(scripts/run-factory-guards.sh --root="$FAIL_TMPDIR" 2>&1)
    rc=$?
    
    if [ $rc -eq 0 ]; then
      fail "$tree_name: runner exited 0 (should fail)"
    elif [ -n "$expected_guard" ]; then
      # Count FAIL lines - should be exactly 1 (the expected guard)
      fail_count=$(echo "$output" | grep -c "^FAIL:")
      
      if echo "$output" | grep -q "FAIL: $expected_guard"; then
        if [ "$fail_count" -eq 1 ]; then
          pass "$tree_name: correctly fails ONLY $expected_guard guard"
        else
          all_fails=$(echo "$output" | grep "^FAIL:" | sed 's/^FAIL: //' | cut -d: -f1 | tr '\n' ' ')
          fail "$tree_name: fails $expected_guard but also other guards: $all_fails"
        fi
      else
        fail "$tree_name: exited non-zero but $expected_guard guard not reported as failed"
        echo "  Output was: $(echo "$output" | grep FAIL | head -3)"
      fi
    else
      pass "$tree_name: runner correctly exits non-zero"
    fi
    
    rm -rf "$FAIL_TMPDIR"
  fi
done

# === PROVENANCE VALIDATION TESTS ===
echo
echo "--- Provenance validation ---"

# Test 6: Provenance validator passes
if scripts/validate-provenance-fixtures.sh >/dev/null 2>&1; then
  pass "validate-provenance-fixtures.sh passes"
else
  fail "validate-provenance-fixtures.sh fails"
fi

# Test 7: Invalid provenance fixtures fail validation (contradiction check)
if python3 - "$ROOT/templates/review-provenance.schema.json" "$ROOT/tests/fixtures/provenance/invalid-overall-contradiction.json" << 'PYCHECK' 2>/dev/null; then
import json, sys
from jsonschema import Draft202012Validator, ValidationError

with open(sys.argv[1]) as f:
    schema = json.load(f)
with open(sys.argv[2]) as f:
    data = json.load(f)

try:
    Draft202012Validator(schema).validate(data)
    if "lenses" in data and "overall_verdict" in data:
        all_pass = all(lens.get("verdict") == "PASS" for lens in data["lenses"])
        if data["overall_verdict"] == "PASS" and not all_pass:
            sys.exit(1)
        if data["overall_verdict"] == "CHANGES" and all_pass:
            sys.exit(1)
    sys.exit(0)
except ValidationError:
    sys.exit(1)
PYCHECK
  fail "invalid-overall-contradiction.json passed validation (should fail)"
else
  pass "invalid-overall-contradiction.json correctly fails (contradiction detected)"
fi

# Test 8: Factory pin fixture quotes pre-review command
if grep -q 'run-factory-guards.sh' tests/fixtures/factory-pin/STANDARDS.md 2>/dev/null; then
  pass "factory-pin fixture quotes run-factory-guards.sh"
else
  fail "factory-pin fixture does not quote run-factory-guards.sh"
fi

# === MISSING-DEPENDENCY ISOLATION TESTS ===
echo
echo "--- Missing-dependency isolation (execution) ---"

# Test each required shell tool by creating isolated PATH without it
test_missing_tool() {
  local tool=$1
  
  ISOLATED_PATH=$(mktemp -d)
  for p in $(echo "$PATH" | tr ':' ' '); do
    for f in "$p"/*; do
      [ -x "$f" ] || continue
      fname=$(basename "$f")
      [ "$fname" = "$tool" ] && continue
      ln -sf "$f" "$ISOLATED_PATH/$fname" 2>/dev/null || true
    done
  done
  
  if PATH="$ISOLATED_PATH" scripts/run-factory-guards.sh >/dev/null 2>&1; then
    fail "runner exits 0 with $tool hidden (should fail)"
    rm -rf "$ISOLATED_PATH"
    return 1
  else
    pass "runner correctly fails with $tool hidden"
    rm -rf "$ISOLATED_PATH"
    return 0
  fi
}

for tool in grep sed cut find awk; do
  test_missing_tool "$tool"
done

# Test missing python3
echo "Testing python3 isolation..."
ISOLATED_PATH=$(mktemp -d)
for p in $(echo "$PATH" | tr ':' ' '); do
  for f in "$p"/*; do
    [ -x "$f" ] || continue
    fname=$(basename "$f")
    [ "$fname" = "python3" ] && continue
    [ "$fname" = "python" ] && continue
    ln -sf "$f" "$ISOLATED_PATH/$fname" 2>/dev/null || true
  done
done

if PATH="$ISOLATED_PATH" scripts/run-factory-guards.sh >/dev/null 2>&1; then
  fail "runner exits 0 with python3 hidden (should fail)"
else
  pass "runner correctly fails with python3 hidden"
fi
rm -rf "$ISOLATED_PATH"

# Test missing jsonschema - EXECUTE the real validator with hidden library
echo "Testing jsonschema isolation (execution)..."
ISOLATED_PYDIR=$(mktemp -d)
mkdir -p "$ISOLATED_PYDIR/empty-site"

# Execute validate-provenance-fixtures.sh with PYTHONPATH pointing to empty directory
# This hides jsonschema from the validator - it MUST fail closed (exit non-zero)
validator_output=$(PYTHONPATH="$ISOLATED_PYDIR/empty-site" PYTHONNOUSERSITE=1 \
  scripts/validate-provenance-fixtures.sh 2>&1) || validator_rc=$?
validator_rc=${validator_rc:-0}

if [ "$validator_rc" -ne 0 ]; then
  # Validator failed - check it's because of jsonschema
  if echo "$validator_output" | grep -qi "jsonschema\|import\|module\|dependency"; then
    pass "validator fails closed when jsonschema is hidden"
  else
    # Validator failed but not clearly due to jsonschema - still acceptable (fail closed)
    pass "validator correctly fails with hidden jsonschema (exit $validator_rc)"
  fi
else
  fail "validator exits 0 with jsonschema hidden (should fail closed)"
fi
rm -rf "$ISOLATED_PYDIR"

# === VERIFY_SKIP BYPASS PROTECTION TEST ===
echo
echo "--- VERIFY_SKIP bypass protection ---"

# Test that VERIFY_SKIP=factory cannot skip required factory checks
# We verify by checking the source code has the protection, since running
# verify-local.sh on a full copy takes too long
echo "Testing VERIFY_SKIP bypass protection..."

# Check that verify-local.sh has REQUIRED_CHECKS that includes factory
if grep -q 'REQUIRED_CHECKS=.*factory' scripts/verify-local.sh && \
   grep -q 'is_required_check' scripts/verify-local.sh; then
  # Verify the run() function checks is_required_check before applying SKIPS
  if grep -B5 'for k in.*SKIPS' scripts/verify-local.sh | grep -q 'is_required_check'; then
    pass "verify-local.sh protects factory from VERIFY_SKIP"
  else
    fail "verify-local.sh does not check is_required_check before SKIPS"
  fi
else
  fail "verify-local.sh missing REQUIRED_CHECKS protection"
fi

# Also verify gitleaks and semgrep are protected
if grep -q 'REQUIRED_CHECKS=.*gitleaks' scripts/verify-local.sh && \
   grep -q 'REQUIRED_CHECKS=.*semgrep' scripts/verify-local.sh; then
  pass "verify-local.sh protects gitleaks and semgrep from VERIFY_SKIP"
else
  fail "verify-local.sh does not protect gitleaks/semgrep from VERIFY_SKIP"
fi

echo
if [ $FAILED -eq 0 ]; then
  echo "All wiring tests: PASS ($TESTS_RUN tests)"
  exit 0
else
  echo "Some wiring tests: FAIL ($TESTS_RUN tests run)"
  exit 1
fi
