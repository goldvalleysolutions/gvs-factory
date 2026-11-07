#!/usr/bin/env bash
# run-factory-guards.sh: Run all factory guards before launching a review panel.
# Exit non-zero if any guard fails or if a required dependency is missing.
# Never print a successful overall result when a required guard was skipped.
#
# Required: bash, python3, jsonschema>=4.18 (with Draft202012Validator)
# Usage: scripts/run-factory-guards.sh [--verbose]
set -u

VERBOSE=0
for arg in "$@"; do
  case "$arg" in
    --verbose|-v) VERBOSE=1 ;;
    -h|--help) echo "Usage: $0 [--verbose]"; exit 0 ;;
  esac
done

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "FAIL: not a git repository" >&2; exit 1; }
cd "$ROOT" || exit 1

FAILED=0
GUARDS_RUN=0

log() { [ $VERBOSE -eq 1 ] && echo "$@"; }
fail() { echo "FAIL: $1" >&2; FAILED=1; }
pass() { echo "PASS: $1"; }

# Check required dependencies
check_deps() {
  if ! command -v python3 >/dev/null 2>&1; then
    fail "python3 not installed (required)"
    return 1
  fi

  # Check jsonschema with Draft202012Validator support
  if ! python3 -c "
import sys
try:
    import jsonschema
    from jsonschema import Draft202012Validator
    # Check for minContains/maxContains support (jsonschema >= 4.18)
    if not hasattr(Draft202012Validator, 'VALIDATORS'):
        sys.exit(1)
    # Verify version is adequate
    from packaging import version
    if version.parse(jsonschema.__version__) < version.parse('4.18'):
        sys.exit(1)
except ImportError:
    sys.exit(1)
except Exception:
    sys.exit(1)
sys.exit(0)
" 2>/dev/null; then
    fail "jsonschema>=4.18 not installed or lacks Draft202012Validator (required)"
    return 1
  fi
  return 0
}

# Guard: Canonical lens names
guard_canonical_lens_names() {
  local found=0
  # Check for bare "Tests" as a lens name (without "and evals")
  # Pattern: "Tests" followed by word boundary, not followed by " and evals"
  while IFS= read -r line; do
    # Skip lines that have "Tests and evals"
    if echo "$line" | grep -q "Tests and evals"; then
      continue
    fi
    # Check for bare "Tests" as a lens name in lens lists
    if echo "$line" | grep -Eq '\bTests\b' | grep -Evq 'Tests and evals|tests/|test_|\.test\.|_test\.'; then
      # More precise: check for lens-list context
      if echo "$line" | grep -Eq 'Security.*Code.*\bTests\b|Tests\b.*UX.*Consistency|\bTests\b\s*[,/|]|\[\s*"Tests"\s*\]|enum.*Tests'; then
        fail "canonical-lens-names: bare 'Tests' found (should be 'Tests and evals'): $line"
        found=1
      fi
    fi
  done < <(grep -rn '\bTests\b' docs/ templates/ standards/ 2>/dev/null | grep -v 'Tests and evals' | grep -v 'tests/' | grep -v '\.test\.' | grep -v '_test\.')
  
  [ $found -eq 0 ] && pass "canonical-lens-names"
  GUARDS_RUN=$((GUARDS_RUN + 1))
  return $found
}

# Guard: No "base ref" (should be "base SHA")
guard_starting_commit_wording() {
  local found=0
  for f in templates/lens-launch.md docs/process.md templates/review.md templates/ready-to-merge.md; do
    if [ -f "$f" ] && grep -q "base ref" "$f"; then
      fail "starting-commit-wording: '$f' contains 'base ref' (should be 'base SHA')"
      found=1
    fi
  done
  [ $found -eq 0 ] && pass "starting-commit-wording"
  GUARDS_RUN=$((GUARDS_RUN + 1))
  return $found
}

# Guard: Prompt does not name the PR
guard_prompt_no_pr_number() {
  local found=0
  if [ -f templates/lens-launch.md ]; then
    # Look for PR # in the prompt body (between ## Lens and ### Output format)
    if sed -n '/^## Lens/,/^### Output format/p' templates/lens-launch.md | grep -Eq 'PR #<pr_number>|PR #[0-9]|for PR #'; then
      fail "prompt-no-pr-number: lens-launch.md prompt body names the PR number"
      found=1
    fi
  fi
  [ $found -eq 0 ] && pass "prompt-no-pr-number"
  GUARDS_RUN=$((GUARDS_RUN + 1))
  return $found
}

# Guard: Approval tags have sources
# Only check actual rule headings (lines starting with ###), not prose mentions
guard_approval_tags() {
  local found=0
  while IFS= read -r line; do
    # Check for [APPROVED] without a colon and source on rule heading lines
    if echo "$line" | grep -Eq '\[APPROVED\]' && ! echo "$line" | grep -Eq '\[APPROVED:'; then
      fail "approval-tags: missing source: $line"
      found=1
    fi
  done < <(grep -rn '^### [A-Z].*\[APPROVED' standards/v1/ 2>/dev/null)
  [ $found -eq 0 ] && pass "approval-tags"
  GUARDS_RUN=$((GUARDS_RUN + 1))
  return $found
}

# Guard: Citation resolver - check that cited paths exist
guard_citation_resolver() {
  local found=0
  # Extract paths from [APPROVED: path, ...] patterns
  while IFS= read -r match; do
    local file path
    file=$(echo "$match" | cut -d: -f1)
    # Extract the path after APPROVED:
    path=$(echo "$match" | sed -n 's/.*\[APPROVED: *\([^,\]]*\).*/\1/p' | xargs)
    # Skip non-path sources like "Mike, direct, Nov 2026"
    if [[ "$path" == *"Mike"* ]] || [[ "$path" == *"direct"* ]] || [[ "$path" == *"references"* ]]; then
      continue
    fi
    # Check if path looks like a file path
    if [[ "$path" == *"/"* ]] || [[ "$path" == *".md"* ]]; then
      if [ ! -f "$path" ]; then
        fail "citation-resolver: '$path' cited in '$file' does not exist"
        found=1
      fi
    fi
  done < <(grep -rn '\[APPROVED:' standards/v1/ 2>/dev/null)
  [ $found -eq 0 ] && pass "citation-resolver"
  GUARDS_RUN=$((GUARDS_RUN + 1))
  return $found
}

# Guard: Deviation table fields
guard_deviation_fields() {
  local found=0
  for f in templates/deviations.md standards/v1/blog.md; do
    if [ -f "$f" ]; then
      # Check table rows (lines starting with |)
      while IFS= read -r line; do
        # Skip header and separator rows
        if echo "$line" | grep -Eq '^\|\s*-+\s*\|' || echo "$line" | grep -Eq '^\|\s*Owner\s*\|'; then
          continue
        fi
        # Skip empty placeholder rows
        if echo "$line" | grep -Eq '^\|\s*\|\s*\|'; then
          continue
        fi
        # Check for "To be migrated" without a plan
        if echo "$line" | grep -q "To be migrated" && ! echo "$line" | grep -qi "plan"; then
          fail "deviation-fields: '$f' has 'To be migrated' without a plan: $line"
          found=1
        fi
        # Check for empty Approval column (last column before final |)
        if echo "$line" | grep -Eq '\|\s*\|$'; then
          fail "deviation-fields: '$f' has empty Approval column: $line"
          found=1
        fi
      done < <(grep -E '^\|[^|]+\|[^|]+\|' "$f" 2>/dev/null | grep -v '^\| *Owner' | grep -v '^\| *-')
    fi
  done
  [ $found -eq 0 ] && pass "deviation-fields"
  GUARDS_RUN=$((GUARDS_RUN + 1))
  return $found
}

# Guard: CHANGELOG ID ranges match actual headings
guard_changelog_ranges() {
  local found=0
  if [ -f standards/v1/CHANGELOG.md ]; then
    # Check CM range (strip leading zeros with $((10#...)) for numeric comparison)
    local claimed_cm_raw=$(grep -oE 'CM-01 through CM-[0-9]+' standards/v1/CHANGELOG.md | head -1 | grep -oE 'CM-[0-9]+$' | sed 's/CM-//')
    if [ -n "$claimed_cm_raw" ]; then
      local claimed_cm=$((10#$claimed_cm_raw))
      local actual_cm=$(grep -cE '^### CM-[0-9]+' standards/v1/common.md 2>/dev/null || echo 0)
      if [ "$claimed_cm" != "$actual_cm" ]; then
        fail "changelog-ranges: CHANGELOG claims CM-01 through CM-$claimed_cm_raw but common.md has $actual_cm CM rules"
        found=1
      fi
    fi
    # Check BOT range
    local claimed_bot_raw=$(grep -oE 'BOT-01 through BOT-[0-9]+' standards/v1/CHANGELOG.md | head -1 | grep -oE 'BOT-[0-9]+$' | sed 's/BOT-//')
    if [ -n "$claimed_bot_raw" ]; then
      local claimed_bot=$((10#$claimed_bot_raw))
      local actual_bot=$(grep -cE '^### BOT-[0-9]+' standards/v1/profile-bot.md 2>/dev/null || echo 0)
      if [ "$claimed_bot" != "$actual_bot" ]; then
        fail "changelog-ranges: CHANGELOG claims BOT-01 through BOT-$claimed_bot_raw but profile-bot.md has $actual_bot BOT rules"
        found=1
      fi
    fi
  fi
  [ $found -eq 0 ] && pass "changelog-ranges"
  GUARDS_RUN=$((GUARDS_RUN + 1))
  return $found
}

# Guard: STANDARDS.md pairing with DEVIATIONS.md
guard_standards_pairing() {
  local found=0
  if [ -f DEVIATIONS.md ] && [ ! -f STANDARDS.md ]; then
    fail "standards-pairing: DEVIATIONS.md exists but STANDARDS.md is missing"
    found=1
  fi
  [ $found -eq 0 ] && pass "standards-pairing"
  GUARDS_RUN=$((GUARDS_RUN + 1))
  return $found
}

# Guard: Pin Source URL not pointing at moving branch
guard_pin_source_url() {
  local found=0
  if [ -f templates/standards-pin.md ]; then
    if grep -q '/tree/test/' templates/standards-pin.md; then
      fail "pin-source-url: templates/standards-pin.md Source URL points at moving 'test' branch"
      found=1
    fi
  fi
  [ $found -eq 0 ] && pass "pin-source-url"
  GUARDS_RUN=$((GUARDS_RUN + 1))
  return $found
}

# Guard: Evidence pack heuristic for fake secrets
guard_evidence_secrets() {
  local found=0
  if [ -d evidence ]; then
    # Check for known fake/real token prefixes
    while IFS= read -r match; do
      fail "evidence-secrets: potential secret found: $match"
      found=1
    done < <(grep -rEn 'AKIA[A-Z0-9]{16}|ghp_[a-zA-Z0-9]{36}|sk-[a-zA-Z0-9]{48}|xox[baprs]-[a-zA-Z0-9-]+' evidence/ 2>/dev/null | head -5)
  fi
  [ $found -eq 0 ] && pass "evidence-secrets"
  GUARDS_RUN=$((GUARDS_RUN + 1))
  return $found
}

# Guard: Provenance schema validation
guard_provenance_schema() {
  if [ -f scripts/validate-provenance-fixtures.sh ]; then
    if bash scripts/validate-provenance-fixtures.sh >/dev/null 2>&1; then
      pass "provenance-schema"
    else
      fail "provenance-schema: fixture validation failed"
    fi
  else
    pass "provenance-schema (no fixtures)"
  fi
  GUARDS_RUN=$((GUARDS_RUN + 1))
}

# Guard: Lens heading separator (middot vs colon)
guard_lens_heading_separator() {
  local found=0
  if [ -f templates/lens-launch.md ]; then
    # Check for colon separator instead of middot in lens headings
    if grep -Eq '^## Lens <lens_number>:' templates/lens-launch.md; then
      fail "lens-heading-separator: lens-launch.md uses ':' instead of '·' in lens heading"
      found=1
    fi
  fi
  [ $found -eq 0 ] && pass "lens-heading-separator"
  GUARDS_RUN=$((GUARDS_RUN + 1))
  return $found
}

# Guard: Standards-input example completeness
guard_standards_input_example() {
  local found=0
  if [ -f templates/lens-launch.md ]; then
    # Check that the example mentions profile-web.md and blog.md
    local example_section=$(sed -n '/^## Standards input format/,/^---$/p' templates/lens-launch.md)
    if ! echo "$example_section" | grep -q 'profile-web.md'; then
      fail "standards-input-example: lens-launch.md example does not mention profile-web.md"
      found=1
    fi
    if ! echo "$example_section" | grep -q 'blog.md'; then
      fail "standards-input-example: lens-launch.md example does not mention blog.md"
      found=1
    fi
  fi
  [ $found -eq 0 ] && pass "standards-input-example"
  GUARDS_RUN=$((GUARDS_RUN + 1))
  return $found
}

# Main execution
echo "Factory guards"
echo "=============="
echo

# Check dependencies first
if ! check_deps; then
  echo
  echo "Factory guards: FAIL (missing required dependencies)"
  exit 1
fi

# Run all guards
guard_canonical_lens_names || true
guard_starting_commit_wording || true
guard_prompt_no_pr_number || true
guard_approval_tags || true
guard_citation_resolver || true
guard_deviation_fields || true
guard_changelog_ranges || true
guard_standards_pairing || true
guard_pin_source_url || true
guard_evidence_secrets || true
guard_provenance_schema || true
guard_lens_heading_separator || true
guard_standards_input_example || true

echo
if [ $FAILED -eq 0 ]; then
  echo "Factory guards: PASS ($GUARDS_RUN guards)"
  exit 0
else
  echo "Factory guards: FAIL"
  exit 1
fi
