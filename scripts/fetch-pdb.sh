#!/usr/bin/env bash
# Download public entries from the RCSB PDB into data/ (git-ignored).
#   scripts/fetch-pdb.sh 1TUB 6DPU
# Tries legacy .pdb format first and falls back to .cif for entries too large for it.
# Existing files are kept. Delete one to fetch it again.
set -euo pipefail

[[ $# -gt 0 ]] || { echo "usage: scripts/fetch-pdb.sh <PDB ID> [<PDB ID> ...]" >&2; exit 2; }

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$REPO_ROOT/data"

for raw in "$@"; do
  id="$(printf '%s' "$raw" | tr '[:lower:]' '[:upper:]')"
  [[ "$id" =~ ^[0-9][A-Z0-9]{3}$ ]] || { echo "skip  '$raw' is not a 4-character PDB ID" >&2; continue; }
  if [[ -s "$REPO_ROOT/data/$id.pdb" || -s "$REPO_ROOT/data/$id.cif" ]]; then
    echo "have  data/$id.*"
    continue
  fi
  for ext in pdb cif; do
    dest="$REPO_ROOT/data/$id.$ext"
    if curl -fsSL "https://files.rcsb.org/download/$id.$ext" -o "$dest.part"; then
      mv "$dest.part" "$dest"
      echo "got   data/$id.$ext"
      break
    fi
    rm -f "$dest.part"
    [[ $ext == cif ]] && echo "fail  $id: not found on RCSB" >&2
  done
done
