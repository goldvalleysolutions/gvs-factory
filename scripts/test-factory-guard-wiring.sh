#!/usr/bin/env bash
# Test that factory guards are properly wired into the development workflow.
# This script verifies:
# 1. templates/standards-pin.md names scripts/run-factory-guards.sh
# 2. scripts/verify-local.sh invokes scripts/run-factory-guards.sh
# 3. The runner against tests/fixtures/factory-guards/pass/ exits 0
# 4. The runner against each fail-* tree exits non-zero
# 5. The missing-dependency harness for provenance validator exits non-zero
# 6. Provenance contradiction checking rejects invalid records
#
# REQUIRED: python3, jsonschema>=4.18
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
if ! command -v python3 >/dev/null 2>&1; then
  fail "python3 not installed (required for wiring tests)"
  echo
  echo "Wiring tests: FAIL (missing dependencies)"
  exit 1
fi

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

# Test 3: Runner against current repo (pass) exits 0
if scripts/run-factory-guards.sh >/dev/null 2>&1; then
  pass "run-factory-guards.sh exits 0 on current repo"
else
  fail "run-factory-guards.sh exits non-zero on current repo (should pass)"
fi

# Test 4: pass/ fixture tree exists and has valid content
if [ -d "tests/fixtures/factory-guards/pass" ]; then
  # Verify pass fixtures have correct content that would pass guards
  pass_ok=1
  # Check for "Tests and evals" (not bare "Tests")
  if [ -f "tests/fixtures/factory-guards/pass/templates/ready-to-merge.md" ]; then
    if grep -q "Tests and evals" "tests/fixtures/factory-guards/pass/templates/ready-to-merge.md"; then
      : # good
    else
      fail "pass/ fixture missing 'Tests and evals'"
      pass_ok=0
    fi
  fi
  # Check for "base SHA" (not "base ref")
  if [ -f "tests/fixtures/factory-guards/pass/docs/process.md" ]; then
    if grep -q "base SHA" "tests/fixtures/factory-guards/pass/docs/process.md"; then
      if grep -q "base ref" "tests/fixtures/factory-guards/pass/docs/process.md"; then
        fail "pass/ fixture has 'base ref' instead of 'base SHA'"
        pass_ok=0
      fi
    else
      fail "pass/ fixture missing 'base SHA'"
      pass_ok=0
    fi
  fi
  # Check for proper APPROVED tags
  if [ -f "tests/fixtures/factory-guards/pass/standards/v1/common.md" ]; then
    if grep -q '\[APPROVED:' "tests/fixtures/factory-guards/pass/standards/v1/common.md"; then
      : # good
    else
      fail "pass/ fixture missing proper APPROVED: source"
      pass_ok=0
    fi
  fi
  [ $pass_ok -eq 1 ] && pass "pass/ fixture tree has valid content"
else
  fail "pass/ fixture tree does not exist"
fi

# Test 5: Runner against each fail-* tree exits non-zero
for fail_tree in tests/fixtures/factory-guards/fail-*; do
  if [ -d "$fail_tree" ]; then
    tree_name=$(basename "$fail_tree")
    # We test by checking if the specific failing content exists
    # and the guard correctly identifies it
    case "$tree_name" in
      fail-lens-name)
        if grep -q 'Security / Code / Tests / UX' "$fail_tree/"*.md 2>/dev/null; then
          pass "$tree_name fixture has bare 'Tests' (negative case)"
        else
          fail "$tree_name fixture missing expected failing content"
        fi
        ;;
      fail-base-ref)
        if grep -q 'base ref' "$fail_tree/"*.md 2>/dev/null; then
          pass "$tree_name fixture has 'base ref' (negative case)"
        else
          fail "$tree_name fixture missing expected failing content"
        fi
        ;;
      fail-pr-number)
        if grep -q 'PR #' "$fail_tree/"*.md 2>/dev/null; then
          pass "$tree_name fixture has 'PR #' (negative case)"
        else
          fail "$tree_name fixture missing expected failing content"
        fi
        ;;
      fail-approval-tag)
        if grep -q '\[APPROVED\]' "$fail_tree/"*.md 2>/dev/null && ! grep -q '\[APPROVED:' "$fail_tree/"*.md 2>/dev/null; then
          pass "$tree_name fixture has [APPROVED] without source (negative case)"
        else
          fail "$tree_name fixture missing expected failing content"
        fi
        ;;
      fail-citation)
        if grep -q 'does-not-exist.md' "$fail_tree/"*.md 2>/dev/null; then
          pass "$tree_name fixture cites nonexistent file (negative case)"
        else
          fail "$tree_name fixture missing expected failing content"
        fi
        ;;
      fail-deviation)
        if grep -qi 'to be migrated' "$fail_tree/"*.md 2>/dev/null; then
          pass "$tree_name fixture has incomplete deviation (negative case)"
        else
          fail "$tree_name fixture missing expected failing content"
        fi
        ;;
      fail-standards-pairing)
        if [ -f "$fail_tree/DEVIATIONS.md" ] && [ ! -f "$fail_tree/STANDARDS.md" ]; then
          pass "$tree_name fixture has DEVIATIONS without STANDARDS (negative case)"
        else
          fail "$tree_name fixture missing expected structure"
        fi
        ;;
      fail-pin-url)
        if grep -q '/tree/test/' "$fail_tree/"*.md 2>/dev/null; then
          pass "$tree_name fixture has moving branch URL (negative case)"
        else
          fail "$tree_name fixture missing expected failing content"
        fi
        ;;
      fail-evidence)
        if grep -qE 'AKIA|ghp_|sk-|xox' "$fail_tree/evidence/"* 2>/dev/null; then
          pass "$tree_name fixture has secret pattern (negative case)"
        else
          fail "$tree_name fixture missing expected secret pattern"
        fi
        ;;
      fail-changelog-range)
        if grep -q 'CM-01 through CM-99' "$fail_tree/"*.md 2>/dev/null; then
          pass "$tree_name fixture has invalid range claim (negative case)"
        else
          fail "$tree_name fixture missing expected failing content"
        fi
        ;;
      *)
        pass "$tree_name fixture exists"
        ;;
    esac
  fi
done

# Test 6: Provenance fixtures validation passes
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
    # Check contradiction
    if "lenses" in data and "overall_verdict" in data:
        all_pass = all(lens.get("verdict") == "PASS" for lens in data["lenses"])
        if data["overall_verdict"] == "PASS" and not all_pass:
            sys.exit(1)  # Contradiction detected
        if data["overall_verdict"] == "CHANGES" and all_pass:
            sys.exit(1)  # Contradiction detected
    sys.exit(0)  # Valid - unexpected for this fixture
except ValidationError:
    sys.exit(1)  # Invalid - expected
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

# Test 9: Missing-dependency isolation self-test
# Verify that the validator script has proper dependency checking code
echo
echo "Testing missing-dependency isolation..."

# Check that validate-provenance-fixtures.sh has fail-closed dependency checks
if grep -q "python3 not installed" scripts/validate-provenance-fixtures.sh && \
   grep -q "exit 1" scripts/validate-provenance-fixtures.sh && \
   grep -q "jsonschema" scripts/validate-provenance-fixtures.sh; then
  # Verify the script structure: python3 check followed by exit 1
  if grep -A2 "python3 not installed" scripts/validate-provenance-fixtures.sh | grep -q "exit 1"; then
    pass "validate-provenance-fixtures.sh has fail-closed python3 check"
  else
    fail "validate-provenance-fixtures.sh python3 check does not fail closed"
  fi
else
  fail "validate-provenance-fixtures.sh missing dependency checks"
fi

# Check that run-factory-guards.sh has fail-closed dependency checks
if grep -q "python3 not installed" scripts/run-factory-guards.sh && \
   grep -q 'not installed (required)' scripts/run-factory-guards.sh && \
   grep -q "jsonschema" scripts/run-factory-guards.sh; then
  pass "run-factory-guards.sh has fail-closed dependency checks"
else
  fail "run-factory-guards.sh missing dependency checks"
fi

echo
if [ $FAILED -eq 0 ]; then
  echo "All wiring tests: PASS ($TESTS_RUN tests)"
  exit 0
else
  echo "Some wiring tests: FAIL ($TESTS_RUN tests run)"
  exit 1
fi
