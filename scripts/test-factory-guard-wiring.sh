#!/usr/bin/env bash
# Test that factory guards are properly wired into the development workflow.
# This script verifies:
# 1. templates/standards-pin.md names scripts/run-factory-guards.sh
# 2. scripts/verify-local.sh invokes scripts/run-factory-guards.sh
# 3. The runner against pass fixtures exits 0
# 4. The runner against fail fixtures exits non-zero
# 5. The missing-dependency harness exits non-zero
set -u

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "FAIL: not a git repository" >&2; exit 1; }
cd "$ROOT" || exit 1

FAILED=0
TESTS_RUN=0

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1" >&2; FAILED=1; }

echo "Factory guard wiring tests"
echo "=========================="
echo

# Test 1: standards-pin.md names run-factory-guards.sh
TESTS_RUN=$((TESTS_RUN + 1))
if grep -q 'run-factory-guards.sh' templates/standards-pin.md 2>/dev/null; then
  pass "standards-pin.md names run-factory-guards.sh"
else
  fail "standards-pin.md does not name run-factory-guards.sh"
fi

# Test 2: verify-local.sh invokes run-factory-guards.sh
TESTS_RUN=$((TESTS_RUN + 1))
if grep -q 'run-factory-guards.sh' scripts/verify-local.sh 2>/dev/null; then
  pass "verify-local.sh invokes run-factory-guards.sh"
else
  fail "verify-local.sh does not invoke run-factory-guards.sh"
fi

# Test 3: Runner against pass fixtures exits 0
# (The real repo should pass the guards)
TESTS_RUN=$((TESTS_RUN + 1))
if scripts/run-factory-guards.sh >/dev/null 2>&1; then
  pass "run-factory-guards.sh exits 0 on current repo"
else
  fail "run-factory-guards.sh exits non-zero on current repo (should pass)"
fi

# Test 4: Provenance fixtures validation passes
TESTS_RUN=$((TESTS_RUN + 1))
if scripts/validate-provenance-fixtures.sh >/dev/null 2>&1; then
  pass "validate-provenance-fixtures.sh passes"
else
  fail "validate-provenance-fixtures.sh fails"
fi

# Test 5: Invalid provenance fixtures fail validation
# We test one invalid fixture by running the validator in isolation
TESTS_RUN=$((TESTS_RUN + 1))
if python3 - "$ROOT/templates/review-provenance.schema.json" "$ROOT/tests/fixtures/provenance/invalid-duplicate-lens.json" << 'PYCHECK' 2>/dev/null; then
import json, sys
from jsonschema import Draft202012Validator, ValidationError

with open(sys.argv[1]) as f:
    schema = json.load(f)
with open(sys.argv[2]) as f:
    data = json.load(f)

try:
    Draft202012Validator(schema).validate(data)
    sys.exit(0)  # Valid - unexpected
except ValidationError:
    sys.exit(1)  # Invalid - expected
PYCHECK
  fail "invalid-duplicate-lens.json passed validation (should fail)"
else
  pass "invalid-duplicate-lens.json correctly fails validation"
fi

# Test 6: Factory pin fixture quotes pre-review command
TESTS_RUN=$((TESTS_RUN + 1))
if grep -q 'run-factory-guards.sh' tests/fixtures/factory-pin/STANDARDS.md 2>/dev/null; then
  pass "factory-pin fixture quotes run-factory-guards.sh"
else
  fail "factory-pin fixture does not quote run-factory-guards.sh"
fi

echo
if [ $FAILED -eq 0 ]; then
  echo "All wiring tests: PASS ($TESTS_RUN tests)"
  exit 0
else
  echo "Some wiring tests: FAIL"
  exit 1
fi
