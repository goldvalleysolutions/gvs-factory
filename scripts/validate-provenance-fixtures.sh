#!/usr/bin/env bash
# Validate provenance fixtures against the schema.
# Exit 0 if valid-five passes and all invalid fixtures fail, exit 1 otherwise.
#
# REQUIRED: python3, jsonschema>=4.18 (with Draft202012Validator and minContains/maxContains)
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

# Check jsonschema with version and Draft202012Validator - FAIL if missing or too old
python3 << 'PYCHECK'
import sys
try:
    import jsonschema
    from jsonschema import Draft202012Validator
    # Verify version >= 4.18 for minContains/maxContains support
    from packaging import version
    if version.parse(jsonschema.__version__) < version.parse("4.18"):
        print(f"FAIL: jsonschema {jsonschema.__version__} too old, need >= 4.18", file=sys.stderr)
        sys.exit(1)
except ImportError as e:
    print(f"FAIL: {e} (required)", file=sys.stderr)
    sys.exit(1)
sys.exit(0)
PYCHECK

if [ $? -ne 0 ]; then
  exit 1
fi

FAILED=0

# Python validator that uses sys.argv for paths (no string interpolation)
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
    
    # Additional check: overall_verdict must match lens verdicts
    if "lenses" in data and "overall_verdict" in data:
        all_pass = all(lens.get("verdict") == "PASS" for lens in data["lenses"])
        if data["overall_verdict"] == "PASS" and not all_pass:
            # Contradiction: claims PASS but not all lenses passed
            sys.exit(1)
        if data["overall_verdict"] == "CHANGES" and all_pass:
            # Contradiction: claims CHANGES but all lenses passed
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

# Validate each fixture
[ -f "$FIXTURES/valid-five.json" ] && validate "$FIXTURES/valid-five.json" "valid"
[ -f "$FIXTURES/valid-all-pass-overall-pass.json" ] && validate "$FIXTURES/valid-all-pass-overall-pass.json" "valid"
[ -f "$FIXTURES/invalid-duplicate-lens.json" ] && validate "$FIXTURES/invalid-duplicate-lens.json" "invalid"
[ -f "$FIXTURES/invalid-missing-lens.json" ] && validate "$FIXTURES/invalid-missing-lens.json" "invalid"
[ -f "$FIXTURES/invalid-malformed.json" ] && validate "$FIXTURES/invalid-malformed.json" "invalid"
[ -f "$FIXTURES/invalid-overall-absent.json" ] && validate "$FIXTURES/invalid-overall-absent.json" "invalid"
[ -f "$FIXTURES/invalid-overall-contradiction.json" ] && validate "$FIXTURES/invalid-overall-contradiction.json" "invalid"
[ -f "$FIXTURES/invalid-all-pass-overall-changes.json" ] && validate "$FIXTURES/invalid-all-pass-overall-changes.json" "invalid"

echo

if [ $FAILED -eq 0 ]; then
  echo "All fixtures: PASS"
  exit 0
else
  echo "Some fixtures: FAIL"
  exit 1
fi
