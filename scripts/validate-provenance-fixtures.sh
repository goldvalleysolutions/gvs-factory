#!/usr/bin/env bash
# Validate provenance fixtures against the schema.
# Exit 0 if valid-five passes and both invalid fixtures fail, exit 1 otherwise.
set -u

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "not a git repository" >&2; exit 2; }
SCHEMA="$ROOT/templates/review-provenance.schema.json"
FIXTURES="$ROOT/tests/fixtures/provenance"

if ! command -v python3 >/dev/null 2>&1; then
  echo "SKIP: python3 not installed"
  exit 0
fi

# Check if jsonschema is available
if ! python3 -c "import jsonschema" 2>/dev/null; then
  echo "SKIP: jsonschema not installed (pip install jsonschema)"
  exit 0
fi

FAILED=0

validate() {
  local fixture=$1 expect=$2 name
  name=$(basename "$fixture")
  if python3 -c "
import json, sys
from jsonschema import validate, ValidationError, Draft202012Validator

with open('$SCHEMA') as f:
    schema = json.load(f)
with open('$fixture') as f:
    data = json.load(f)

try:
    Draft202012Validator(schema).validate(data)
    sys.exit(0)
except ValidationError as e:
    sys.exit(1)
" 2>/dev/null; then
    result="valid"
  else
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
validate "$FIXTURES/valid-five.json" "valid"
validate "$FIXTURES/invalid-duplicate-lens.json" "invalid"
validate "$FIXTURES/invalid-missing-lens.json" "invalid"
echo

if [ $FAILED -eq 0 ]; then
  echo "All fixtures: PASS"
  exit 0
else
  echo "Some fixtures: FAIL"
  exit 1
fi
