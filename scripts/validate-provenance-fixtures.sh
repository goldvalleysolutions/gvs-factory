#!/usr/bin/env bash
# Validate provenance fixtures against the schema.
# Exit 0 if valid fixtures pass and all invalid fixtures fail, exit 1 otherwise.
#
# REQUIRED: python3, jsonschema==4.23.0 (with Draft202012Validator and minContains/maxContains)
# Missing dependencies are FAIL, not SKIP.
set -u

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "FAIL: not a git repository" >&2; exit 1; }
SCHEMA="$ROOT/templates/review-provenance.schema.json"
FIXTURES="$ROOT/tests/fixtures/provenance"

# Check python3 - FAIL if missing, not SKIP
if ! command -v python3 >/dev/null 2>&1; then
  echo "FAIL: python3 not installed (required)"
  exit 1
fi

# Check jsonschema with actual minContains/maxContains capability probe - FAIL if missing or incapable
python3 << 'PYCHECK' 2>/dev/null
import sys
try:
    import jsonschema
    from jsonschema import Draft202012Validator
    from packaging import version
    if version.parse(jsonschema.__version__) < version.parse("4.18"):
        print(f"FAIL: jsonschema {jsonschema.__version__} too old, need >= 4.18", file=sys.stderr)
        sys.exit(1)
    # Actual capability probe: minContains/maxContains must work
    test_schema = {
        "type": "array",
        "contains": {"const": "x"},
        "minContains": 2,
        "maxContains": 3
    }
    # Should pass: exactly 2 x's
    Draft202012Validator(test_schema).validate(["x", "x"])
    # Should pass: exactly 3 x's
    Draft202012Validator(test_schema).validate(["x", "x", "x"])
    # Should fail: only 1 x
    try:
        Draft202012Validator(test_schema).validate(["x"])
        print("FAIL: minContains not enforced", file=sys.stderr)
        sys.exit(1)
    except jsonschema.ValidationError:
        pass  # Expected
    # Should fail: 4 x's exceeds maxContains
    try:
        Draft202012Validator(test_schema).validate(["x", "x", "x", "x"])
        print("FAIL: maxContains not enforced", file=sys.stderr)
        sys.exit(1)
    except jsonschema.ValidationError:
        pass  # Expected
except ImportError as e:
    print(f"FAIL: {e} (required)", file=sys.stderr)
    sys.exit(1)
except Exception as e:
    print(f"FAIL: capability probe failed: {e}", file=sys.stderr)
    sys.exit(1)
sys.exit(0)
PYCHECK

if [ $? -ne 0 ]; then
  echo "FAIL: jsonschema>=4.18 with minContains/maxContains support required"
  exit 1
fi

FAILED=0

# Python validator that uses sys.argv for paths (no string interpolation)
# Includes contradiction checking for actual review records
validate() {
  local fixture=$1 expect=$2 name
  name=$(basename "$fixture")
  
  # Run Python with paths as arguments
  if python3 - "$SCHEMA" "$fixture" << 'PYVALIDATE'
import json
import sys
from jsonschema import Draft202012Validator, ValidationError

schema_path = sys.argv[1]
fixture_path = sys.argv[2]

try:
    with open(schema_path) as f:
        schema = json.load(f)
except json.JSONDecodeError as e:
    print(f"Schema parse error: {e}", file=sys.stderr)
    sys.exit(2)
except FileNotFoundError:
    print(f"Schema not found: {schema_path}", file=sys.stderr)
    sys.exit(2)

try:
    with open(fixture_path) as f:
        data = json.load(f)
except json.JSONDecodeError as e:
    # Malformed JSON is invalid
    sys.exit(1)
except FileNotFoundError:
    print(f"Fixture not found: {fixture_path}", file=sys.stderr)
    sys.exit(2)

try:
    Draft202012Validator(schema).validate(data)
    
    # CONTRADICTION CHECK: overall_verdict must be consistent with lens verdicts
    # This is enforced here for actual review records, not just schema
    if "lenses" in data and "overall_verdict" in data:
        all_pass = all(lens.get("verdict") == "PASS" for lens in data["lenses"])
        if data["overall_verdict"] == "PASS" and not all_pass:
            # Contradiction: claims PASS but not all lenses passed
            print("Contradiction: overall_verdict PASS but not all lenses PASS", file=sys.stderr)
            sys.exit(1)
        if data["overall_verdict"] == "CHANGES" and all_pass:
            # Contradiction: claims CHANGES but all lenses passed
            print("Contradiction: overall_verdict CHANGES but all lenses PASS", file=sys.stderr)
            sys.exit(1)
    
    sys.exit(0)
except ValidationError as e:
    sys.exit(1)
PYVALIDATE
  then
    result="valid"
  else
    rc=$?
    if [ $rc -eq 2 ]; then
      echo "ERROR: file access error for $name"
      FAILED=1
      return
    fi
    result="invalid"
  fi

  if [ "$result" = "$expect" ]; then
    echo "PASS: $name ($expect as expected)"
  else
    echo "FAIL: $name (expected $expect, got $result)"
    FAILED=1
  fi
}

echo "Provenance schema fixture validation"
echo "====================================="

# Check that fixtures directory exists
if [ ! -d "$FIXTURES" ]; then
  echo "FAIL: fixtures directory not found: $FIXTURES"
  exit 1
fi

# Required fixtures - FAIL if any are missing
# Note: Schema now uses four-v1 gate (4 lenses: Security, Code, Tests and evals, UX/Consistency)
REQUIRED_VALID="valid-four.json"
REQUIRED_INVALID="invalid-duplicate-lens.json invalid-missing-lens.json invalid-malformed.json invalid-overall-absent.json invalid-overall-contradiction.json invalid-all-pass-overall-changes.json"

for f in $REQUIRED_VALID; do
  if [ ! -f "$FIXTURES/$f" ]; then
    echo "FAIL: required fixture missing: $f"
    FAILED=1
  fi
done

for f in $REQUIRED_INVALID; do
  if [ ! -f "$FIXTURES/$f" ]; then
    echo "FAIL: required fixture missing: $f"
    FAILED=1
  fi
done

if [ $FAILED -ne 0 ]; then
  echo
  echo "Some fixtures: FAIL (missing required fixtures)"
  exit 1
fi

# Validate required fixtures (four-v1 gate)
echo "--- Four-lens gate (four-v1) fixtures ---"
validate "$FIXTURES/valid-four.json" "valid"
validate "$FIXTURES/invalid-duplicate-lens.json" "invalid"
validate "$FIXTURES/invalid-missing-lens.json" "invalid"
validate "$FIXTURES/invalid-malformed.json" "invalid"
validate "$FIXTURES/invalid-overall-absent.json" "invalid"
validate "$FIXTURES/invalid-overall-contradiction.json" "invalid"
validate "$FIXTURES/invalid-all-pass-overall-changes.json" "invalid"

# Test that old five-lens records are rejected by new four-lens gate
[ -f "$FIXTURES/invalid-five-record-new-gate.json" ] && validate "$FIXTURES/invalid-five-record-new-gate.json" "invalid"
[ -f "$FIXTURES/invalid-old-lens-names.json" ] && validate "$FIXTURES/invalid-old-lens-names.json" "invalid"

# Historical five-lens fixture (valid under OLD schema, invalid under new four-lens gate)
# This documents that old records exist but cannot pass the new gate
echo
echo "--- Historical fixture (five-lens, pre-four-v1) ---"
[ -f "$FIXTURES/valid-five.json" ] && validate "$FIXTURES/valid-five.json" "invalid"

echo

if [ $FAILED -eq 0 ]; then
  echo "All fixtures: PASS"
  exit 0
else
  echo "Some fixtures: FAIL"
  exit 1
fi
