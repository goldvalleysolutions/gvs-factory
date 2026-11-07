#!/usr/bin/env bash
# build-fixture-tree.sh: Build a complete test fixture from shared base + overlay
# Usage: build-fixture-tree.sh <overlay_dir> <output_dir>
# 
# Creates a complete fixture tree in output_dir by:
# 1. Setting up a valid base structure (templates, provenance, etc.)
# 2. Copying overlay files on top (the failing content)
# 3. Initializing git
#
# This allows each fail-* fixture to contain ONLY its offending file.
set -u

OVERLAY_DIR=$1
OUTPUT_DIR=$2

if [ -z "$OVERLAY_DIR" ] || [ -z "$OUTPUT_DIR" ]; then
  echo "Usage: $0 <overlay_dir> <output_dir>" >&2
  exit 1
fi

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || ROOT="."

# Create output directory
mkdir -p "$OUTPUT_DIR"

# === BASE STRUCTURE ===

# Templates (valid content)
mkdir -p "$OUTPUT_DIR/templates"
cat > "$OUTPUT_DIR/templates/standards-pin.md" << 'EOF'
# Standards pin
**Source:** https://github.com/example/factory/tree/v1.0.0/standards/v1
Run scripts/run-factory-guards.sh before review.
EOF

cat > "$OUTPUT_DIR/templates/lens-launch.md" << 'EOF'
## Lens <lens_number> · <Lens name>
Review at base SHA and head SHA.
## Standards input format
Example: profile-web.md, blog.md
EOF

# Copy schema
cp "$ROOT/templates/review-provenance.schema.json" "$OUTPUT_DIR/templates/" 2>/dev/null || true

# Scripts
mkdir -p "$OUTPUT_DIR/scripts"
cp "$ROOT/scripts/validate-provenance-fixtures.sh" "$OUTPUT_DIR/scripts/" 2>/dev/null || true

# Provenance fixtures (required for provenance-schema guard)
mkdir -p "$OUTPUT_DIR/tests/fixtures/provenance"
cp "$ROOT/tests/fixtures/provenance/"*.json "$OUTPUT_DIR/tests/fixtures/provenance/" 2>/dev/null || true

# Valid standards (empty or minimal)
mkdir -p "$OUTPUT_DIR/standards/v1"
cat > "$OUTPUT_DIR/standards/v1/common.md" << 'EOF'
# Common standards
EOF

# Docs directory (for citation tests)
mkdir -p "$OUTPUT_DIR/docs"

# === APPLY OVERLAY ===
# Copy overlay files on top (these contain the failing content)
if [ -d "$OVERLAY_DIR" ]; then
  cp -r "$OVERLAY_DIR"/* "$OUTPUT_DIR/" 2>/dev/null || true
fi

# === INITIALIZE GIT ===
(cd "$OUTPUT_DIR" && git init -q && git add -A && git commit -q -m "test fixture" 2>/dev/null) || true

exit 0
