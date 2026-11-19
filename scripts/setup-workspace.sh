#!/usr/bin/env bash
# One-time setup for each clone of StructChem. Safe to re-run. Installs nothing.
#   scripts/setup-workspace.sh
# - Enables the leak-guard pre-commit hook (git config core.hooksPath scripts/hooks).
# - Checks that private and local paths are git-ignored.
# - Checks that nothing private is already tracked.
# - Reports whether the private companion repo (StructChemAIDocs/) is present. It's optional.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
status=0

git config core.hooksPath scripts/hooks
chmod +x scripts/hooks/pre-commit scripts/hooks/pre-push scripts/*.sh 2>/dev/null || true
echo "ok    pre-commit + pre-push guards enabled (core.hooksPath = scripts/hooks)"

public_url="$(git remote get-url origin 2>/dev/null || true)"
if printf '%s' "$public_url" | grep -qi 'StructChemAIDocs'; then
  echo "FAIL  public origin points at the private repo: $public_url"
  echo "        fix: git remote set-url origin <StructChem URL>"
  status=1
fi

for probe in StructChemAIDocs/README.md data/example.pdb out/example.png .tmp-data/example \
             References/example .env .mcp.json .claude/settings.local.json; do
  if git check-ignore -q --no-index "$probe"; then
    echo "ok    ignored: $probe"
  else
    echo "FAIL  not ignored: $probe   (fix .gitignore)"
    status=1
  fi
done

pattern="$(tr -d '\r\n' < scripts/hooks/private-paths.ere)"
tracked="$( (git ls-files 2>/dev/null || true) | grep -Ei "$pattern" || true)"
if [[ -n "$tracked" ]]; then
  echo "FAIL  private or data files are tracked:"
  printf '        %s\n' $tracked
  status=1
else
  echo "ok    no private or data files tracked"
fi

if [[ -d StructChemAIDocs/.git ]]; then
  echo "info  private companion repo present: StructChemAIDocs/ (team setup)"
  if [[ -f StructChemAIDocs/hooks/pre-push ]]; then
    git -C StructChemAIDocs config core.hooksPath hooks
    chmod +x StructChemAIDocs/hooks/* 2>/dev/null || true
    echo "ok    private pre-push guard enabled (StructChemAIDocs core.hooksPath = hooks)"
  else
    echo "FAIL  StructChemAIDocs/hooks/pre-push missing (pull the private repo)"
    status=1
  fi
  private_url="$(git -C StructChemAIDocs remote get-url origin 2>/dev/null || true)"
  if [[ -n "$private_url" ]] && ! printf '%s' "$private_url" | grep -qi 'StructChemAIDocs'; then
    echo "FAIL  private origin is not the StructChemAIDocs repo: $private_url"
    status=1
  fi
else
  echo "info  no private companion repo, which is fine for external users. Collaborators: see README.md"
fi

exit $status
