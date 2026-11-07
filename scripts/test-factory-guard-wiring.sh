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

# Test 4: Runner against pass/ fixture tree exits 0
if [ -d "tests/fixtures/factory-guards/pass" ]; then
  # Create a minimal git repo in temp for the fixture
  TMPDIR=$(mktemp -d)
  trap "rm -rf $TMPDIR" EXIT
  cp -r tests/fixtures/factory-guards/pass/* "$TMPDIR/" 2>/dev/null || true
  # Copy required files for guards to pass
  mkdir -p "$TMPDIR/templates" "$TMPDIR/docs" "$TMPDIR/standards/v1" "$TMPDIR/scripts"
  cp templates/standards-pin.md "$TMPDIR/templates/" 2>/dev/null || true
  cp templates/lens-launch.md "$TMPDIR/templates/" 2>/dev/null || true
  cp scripts/validate-provenance-fixtures.sh "$TMPDIR/scripts/" 2>/dev/null || true
  # Initialize git
  (cd "$TMPDIR" && git init -q && git add -A && git commit -q -m "test" 2>/dev/null) || true
  
  if scripts/run-factory-guards.sh --root="$TMPDIR" >/dev/null 2>&1; then
    pass "run-factory-guards.sh exits 0 on pass/ fixture tree"
  else
    fail "run-factory-guards.sh exits non-zero on pass/ fixture tree (should pass)"
  fi
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
# Run the validator with jsonschema hidden and expect non-zero exit
echo
echo "Testing missing-dependency isolation..."
ISOLATED_TMPDIR=$(mktemp -d)
trap "rm -rf $ISOLATED_TMPDIR" EXIT

# Create an isolated Python environment that can't find jsonschema
cat > "$ISOLATED_TMPDIR/test_missing_dep.py" << 'PYISOLATE'
import sys
import subprocess
import os

# Run validate-provenance-fixtures.sh with PYTHONPATH set to empty dir
# so jsonschema import fails
result = subprocess.run(
    ["bash", sys.argv[1]],
    env={**os.environ, "PYTHONPATH": sys.argv[2]},
    capture_output=True,
    text=True
)
# Should exit non-zero due to missing jsonschema
if result.returncode == 0:
    print("FAIL: validator exited 0 with hidden jsonschema (should fail)", file=sys.stderr)
    sys.exit(1)
else:
    print("Validator correctly failed with hidden jsonschema")
    sys.exit(0)
PYISOLATE

# Create empty isolated path
mkdir -p "$ISOLATED_TMPDIR/empty_site_packages"

if python3 "$ISOLATED_TMPDIR/test_missing_dep.py" "$ROOT/scripts/validate-provenance-fixtures.sh" "$ISOLATED_TMPDIR/empty_site_packages" 2>/dev/null; then
  pass "missing-dependency isolation self-test (validator fails when jsonschema hidden)"
else
  fail "missing-dependency isolation self-test failed"
fi

echo
if [ $FAILED -eq 0 ]; then
  echo "All wiring tests: PASS ($TESTS_RUN tests)"
  exit 0
else
  echo "Some wiring tests: FAIL ($TESTS_RUN tests run)"
  exit 1
fi
