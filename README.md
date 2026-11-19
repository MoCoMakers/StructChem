# StructChem

Tooling for viewing and, later, modelling tubulin and microtubule structures. It's built so that people and LLM agents can drive the same tools. Every tool runs from a Docker image, so nothing is installed on your machine.

## Quickstart

Prerequisites: Docker Desktop (WSL2 backend on Windows), and Git Bash or a WSL shell. Run everything from the repo root.

```sh
scripts/setup-workspace.sh                 # once per clone: enables the commit guard, checks ignores
docker build -t structchem-pymol docker/pymol
scripts/fetch-pdb.sh 1TUB                  # public PDB entry → data/1TUB.pdb (git-ignored)
scripts/pymol-run.sh scripts/pymol/view_1tub.pml        # GUI window
scripts/pymol-run.sh -cq scripts/pymol/view_1tub.pml \
  -d "png out/1tub.png, width=1600, height=1200, dpi=150, ray=1"   # headless render to out/
```

Any public RCSB entry works with `scripts/fetch-pdb.sh`. You can also put your own structure files in `data/`.

## Layout

| Path | What |
|---|---|
| `docker/<tool>/` | One image per tool, with its own README ([PyMOL](docker/pymol/README.md)) |
| `scripts/` | Wrappers that run the tools, plus `fetch-pdb.sh`, `setup-workspace.sh` and the commit guard in `hooks/` |
| `docs/runbooks/` | How-to guides for people and agents ([PyMOL usage](docs/runbooks/pymol-usage-guide.md)) |
| `data/`, `out/` | Your structure files and tool output. Local only, git-ignored |
| `AGENTS.md` | Instructions for AI coding agents (`CLAUDE.md` imports it) |

## For project collaborators

The team keeps its data, notes and planning in a private companion repo, cloned inside this one at `StructChemAIDocs/` and ignored by git here. **You don't need it to use StructChem.** If you're collaborating with the team and need it, contact the maintainers (contact channel: TODO), then:

```sh
git clone git@github.com:MoCoMakers/StructChemAIDocs.git StructChemAIDocs
scripts/setup-workspace.sh
```

How the two repos fit together, and why: [docs/two-repo-workspace.md](docs/two-repo-workspace.md).

## Licence

TODO. Not yet chosen.
