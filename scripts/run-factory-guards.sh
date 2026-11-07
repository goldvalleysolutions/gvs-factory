#!/usr/bin/env bash
# run-factory-guards.sh: Run all factory guards before launching a review panel.
# Exit non-zero if any guard fails or if a required dependency is missing.
# Never print a successful overall result when a required guard was skipped.
#
# Required: bash, grep, sed, cut, xargs, python3, jsonschema>=4.18
# Usage: scripts/run-factory-guards.sh [--verbose] [--root DIR]
set -u

VERBOSE=0
TARGET_ROOT=""
for arg in "$@"; do
  case "$arg" in
    --verbose|-v) VERBOSE=1 ;;
    --root=*) TARGET_ROOT="${arg#--root=}" ;;
    -h|--help) echo "Usage: $0 [--verbose] [--root DIR]"; exit 0 ;;
  esac
done

if [ -n "$TARGET_ROOT" ]; then
  ROOT="$TARGET_ROOT"
else
  ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "FAIL: not a git repository" >&2; exit 1; }
fi
cd "$ROOT" || exit 1

FAILED=0
GUARDS_RUN=0

log() { [ $VERBOSE -eq 1 ] && echo "$@"; }
fail() { echo "FAIL: $1" >&2; FAILED=1; }
pass() { echo "PASS: $1"; }

# Check ALL required dependencies up front - never false PASS
check_deps() {
  local missing=0

  # Check shell tools
  for cmd in grep sed cut xargs; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      fail "$cmd not installed (required)"
      missing=1
    fi
  done

  if ! command -v python3 >/dev/null 2>&1; then
    fail "python3 not installed (required)"
    missing=1
  fi

  # Check jsonschema with Draft202012Validator and minContains/maxContains support
  if [ $missing -eq 0 ]; then
    if ! python3 << 'PYCHECK' 2>/dev/null; then
import sys
try:
    import jsonschema
    from jsonschema import Draft202012Validator
    from packaging import version
    if version.parse(jsonschema.__version__) < version.parse("4.18"):
        print(f"jsonschema {jsonschema.__version__} too old, need >= 4.18", file=sys.stderr)
        sys.exit(1)
    # Actual capability probe: minContains/maxContains
    test_schema = {
        "type": "array",
        "contains": {"const": "x"},
        "minContains": 1,
        "maxContains": 2
    }
    Draft202012Validator(test_schema).validate(["x"])
    Draft202012Validator(test_schema).validate(["x", "x"])
    try:
        Draft202012Validator(test_schema).validate(["x", "x", "x"])
        sys.exit(1)  # Should have failed
    except jsonschema.ValidationError:
        pass  # Expected
except ImportError as e:
    print(f"{e}", file=sys.stderr)
    sys.exit(1)
except Exception as e:
    print(f"jsonschema capability check failed: {e}", file=sys.stderr)
    sys.exit(1)
sys.exit(0)
PYCHECK
      fail "jsonschema>=4.18 not installed or lacks minContains/maxContains (required)"
      missing=1
    fi
  fi

  return $missing
}

# Guard: Canonical lens names
# Canonical list: Security, Code, Tests and evals, UX, Consistency
guard_canonical_lens_names() {
  local found=0
  # Search for lens-list contexts with bare "Tests" (without "and evals")
  while IFS= read -r file; do
    while IFS= read -r line; do
      # Skip lines containing "Tests and evals"
      if echo "$line" | grep -q "Tests and evals"; then
        continue
      fi
      # Check for lens-list patterns with bare "Tests"
      if echo "$line" | grep -Eq 'Security[[:space:]]*[/,|][[:space:]]*Code[[:space:]]*[/,|][[:space:]]*Tests[[:space:]]*[/,|]'; then
        fail "canonical-lens-names: bare 'Tests' in lens list (should be 'Tests and evals'): $(basename "$file")"
        found=1
      fi
      if echo "$line" | grep -Eq 'Tests[[:space:]]*[/,|][[:space:]]*(UX|Consistency)'; then
        if ! echo "$line" | grep -q "Tests and evals"; then
          fail "canonical-lens-names: bare 'Tests' in lens list (should be 'Tests and evals'): $(basename "$file")"
          found=1
        fi
      fi
      # Check schema enum
      if echo "$line" | grep -Eq '"Tests"[[:space:]]*[,\]]' && ! echo "$line" | grep -q '"Tests and evals"'; then
        fail "canonical-lens-names: bare 'Tests' in enum (should be 'Tests and evals'): $(basename "$file")"
        found=1
      fi
    done < "$file"
  done < <(find docs/ templates/ standards/ -name '*.md' -o -name '*.json' 2>/dev/null)
  
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
# Check rule headings in standards/v1/ and templates - reject [APPROVED] without ": source"
guard_approval_tags() {
  local found=0
  # Check for [APPROVED] without a colon and non-empty source
  while IFS= read -r match; do
    local file linenum content
    file=$(echo "$match" | cut -d: -f1)
    linenum=$(echo "$match" | cut -d: -f2)
    content=$(echo "$match" | cut -d: -f3-)
    # Check for [APPROVED] without colon or with empty source after colon
    if echo "$content" | grep -Eq '\[APPROVED\]'; then
      fail "approval-tags: missing source at $file:$linenum"
      found=1
    elif echo "$content" | grep -Eq '\[APPROVED:[[:space:]]*\]'; then
      fail "approval-tags: empty source at $file:$linenum"
      found=1
    fi
  done < <(grep -rn '^###.*\[APPROVED' standards/v1/ 2>/dev/null)
  [ $found -eq 0 ] && pass "approval-tags"
  GUARDS_RUN=$((GUARDS_RUN + 1))
  return $found
}

# Guard: Citation resolver - check that cited paths exist
guard_citation_resolver() {
  local found=0
  while IFS= read -r match; do
    local file path
    file=$(echo "$match" | cut -d: -f1)
    path=$(echo "$match" | sed -n 's/.*\[APPROVED: *\([^,\]]*\).*/\1/p' | xargs 2>/dev/null || true)
    # Skip non-path sources
    if [[ -z "$path" ]] || [[ "$path" == *"Mike"* ]] || [[ "$path" == *"direct"* ]] || [[ "$path" == *"references"* ]]; then
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

# Guard: Deviation and example table fields
# Check templates/deviations.md, standards/v1/blog.md, and root DEVIATIONS.md
guard_deviation_fields() {
  local found=0
  local files_to_check="templates/deviations.md standards/v1/blog.md"
  [ -f "DEVIATIONS.md" ] && files_to_check="$files_to_check DEVIATIONS.md"
  
  for f in $files_to_check; do
    if [ -f "$f" ]; then
      local in_table=0
      while IFS= read -r line; do
        # Detect table start (header row with Owner)
        if echo "$line" | grep -Eq '^\|[[:space:]]*Owner[[:space:]]*\|'; then
          in_table=1
          continue
        fi
        # Skip separator rows
        if echo "$line" | grep -Eq '^\|[[:space:]]*-+[[:space:]]*\|'; then
          continue
        fi
        # Process data rows
        if [ $in_table -eq 1 ] && echo "$line" | grep -Eq '^\|'; then
          # Parse columns: | Owner | Paths | Rule ID | Reason | Target | Approval |
          local owner=$(echo "$line" | awk -F'|' '{print $2}' | xargs 2>/dev/null || true)
          local paths=$(echo "$line" | awk -F'|' '{print $3}' | xargs 2>/dev/null || true)
          local ruleid=$(echo "$line" | awk -F'|' '{print $4}' | xargs 2>/dev/null || true)
          local approval=$(echo "$line" | awk -F'|' '{print $(NF-1)}' | xargs 2>/dev/null || true)
          
          # Skip placeholder rows (templates have <name> or empty owner)
          if [ -z "$owner" ] || [[ "$owner" == "<"* ]]; then
            continue
          fi
          
          # Check for "To be migrated" without plan
          if echo "$line" | grep -qi "to be migrated" && ! echo "$line" | grep -qi "plan"; then
            fail "deviation-fields: '$f' has 'To be migrated' without plan"
            found=1
          fi
          
          # Check for empty Approval column on real data rows
          if [ -z "$approval" ]; then
            fail "deviation-fields: '$f' has empty Approval column for owner '$owner'"
            found=1
          fi
        fi
        # End of table
        if [ $in_table -eq 1 ] && ! echo "$line" | grep -Eq '^\|'; then
          in_table=0
        fi
      done < "$f"
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
    # Check CM range
    local claimed_cm_raw=$(grep -oE 'CM-01 through CM-[0-9]+' standards/v1/CHANGELOG.md | head -1 | grep -oE '[0-9]+$' || true)
    if [ -n "$claimed_cm_raw" ]; then
      local claimed_cm=$((10#$claimed_cm_raw))
      local actual_cm=$(grep -cE '^### CM-[0-9]+' standards/v1/common.md 2>/dev/null || echo 0)
      if [ "$claimed_cm" -ne "$actual_cm" ]; then
        fail "changelog-ranges: CHANGELOG claims CM-01 through CM-$claimed_cm_raw but common.md has $actual_cm CM rules"
        found=1
      fi
    fi
    # Check BOT range
    local claimed_bot_raw=$(grep -oE 'BOT-01 through BOT-[0-9]+' standards/v1/CHANGELOG.md | head -1 | grep -oE '[0-9]+$' || true)
    if [ -n "$claimed_bot_raw" ]; then
      local claimed_bot=$((10#$claimed_bot_raw))
      local actual_bot=$(grep -cE '^### BOT-[0-9]+' standards/v1/profile-bot.md 2>/dev/null || echo 0)
      if [ "$claimed_bot" -ne "$actual_bot" ]; then
        fail "changelog-ranges: CHANGELOG claims BOT-01 through BOT-$claimed_bot_raw but profile-bot.md has $actual_bot BOT rules"
        found=1
      fi
    fi
    # Check WEB range
    local claimed_web_raw=$(grep -oE 'WEB-01 through WEB-[0-9]+' standards/v1/CHANGELOG.md | head -1 | grep -oE '[0-9]+$' || true)
    if [ -n "$claimed_web_raw" ]; then
      local claimed_web=$((10#$claimed_web_raw))
      local actual_web=$(grep -cE '^### WEB-[0-9]+' standards/v1/profile-web.md 2>/dev/null || echo 0)
      if [ "$claimed_web" -ne "$actual_web" ]; then
        fail "changelog-ranges: CHANGELOG claims WEB-01 through WEB-$claimed_web_raw but profile-web.md has $actual_web WEB rules"
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

# Guard: Evidence pack heuristic for secrets
# NEVER print the secret-containing line - only report type and location
guard_evidence_secrets() {
  local found=0
  if [ -d evidence ]; then
    # AWS Access Key ID pattern
    while IFS= read -r match; do
      local file=$(echo "$match" | cut -d: -f1)
      local linenum=$(echo "$match" | cut -d: -f2)
      fail "evidence-secrets: AWS key pattern at $file:$linenum"
      found=1
    done < <(grep -rEn 'AKIA[A-Z0-9]{16}' evidence/ 2>/dev/null | head -5 | cut -d: -f1-2)
    
    # GitHub PAT pattern
    while IFS= read -r match; do
      local file=$(echo "$match" | cut -d: -f1)
      local linenum=$(echo "$match" | cut -d: -f2)
      fail "evidence-secrets: GitHub token pattern at $file:$linenum"
      found=1
    done < <(grep -rEn 'ghp_[a-zA-Z0-9]{36}' evidence/ 2>/dev/null | head -5 | cut -d: -f1-2)
    
    # OpenAI/Anthropic key pattern
    while IFS= read -r match; do
      local file=$(echo "$match" | cut -d: -f1)
      local linenum=$(echo "$match" | cut -d: -f2)
      fail "evidence-secrets: API key pattern at $file:$linenum"
      found=1
    done < <(grep -rEn 'sk-[a-zA-Z0-9]{48}' evidence/ 2>/dev/null | head -5 | cut -d: -f1-2)
    
    # Slack token pattern
    while IFS= read -r match; do
      local file=$(echo "$match" | cut -d: -f1)
      local linenum=$(echo "$match" | cut -d: -f2)
      fail "evidence-secrets: Slack token pattern at $file:$linenum"
      found=1
    done < <(grep -rEn 'xox[baprs]-[a-zA-Z0-9-]+' evidence/ 2>/dev/null | head -5 | cut -d: -f1-2)
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
    fail "provenance-schema: validate-provenance-fixtures.sh not found"
  fi
  GUARDS_RUN=$((GUARDS_RUN + 1))
}

# Guard: Lens heading separator (middot vs colon)
guard_lens_heading_separator() {
  local found=0
  if [ -f templates/lens-launch.md ]; then
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

# Check dependencies first - exit immediately if any missing
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
