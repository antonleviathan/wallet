#!/bin/sh
set -eu

# Resolve repository root (same as build.sh)
DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel)"

# Fixed paths (no overrides)
OCI_TAR="$REPO_ROOT/build/oci/zallet.tar"
BIN_PATH="/usr/local/bin/zallet"
OUT_BIN="$REPO_ROOT/binary/zallet"

mkdir -p "$(dirname "$OUT_BIN")"

# Normalize path for layer tarballs (no leading slash)
bp="${BIN_PATH#/}"

# 1) Manifest digest from index.json
manifest_digest="$(tar -xOf "$OCI_TAR" index.json \
  | jq -r '.manifests[0].digest | ltrimstr("sha256:")')"

# 2) Stream layer digests (first -> last)
#    For each layer, try to extract the file; if it exists, overwrite OUT_BIN.
#    At the end, OUT_BIN contains the file from the last layer that had it.
tar -xOf "$OCI_TAR" "blobs/sha256/$manifest_digest" \
| jq -r '.layers[].digest | ltrimstr("sha256:")' \
| while IFS= read -r d; do
    # Try to cat the file from this layer (supports gzip or plain)
    if tar -xOf "$OCI_TAR" "blobs/sha256/$d" \
       | (gzip -dc 2>/dev/null || cat) \
       | tar -xO -f - "$bp" > "$OUT_BIN.tmp" 2>/dev/null; then
      mv "$OUT_BIN.tmp" "$OUT_BIN"
    fi
  done

# 3) Validate result
if [ -f "$OUT_BIN" ]; then
  chmod +x "$OUT_BIN"
  echo "Binary extracted to $OUT_BIN"
else
  echo "Error: $bp not found in any layer" >&2
  exit 2
fi
