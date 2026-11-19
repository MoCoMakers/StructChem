# AGENTS.md

StructChem: Docker-packaged tools for viewing and modelling tubulin and microtubule structures, driven by people and LLM agents alike. Start with [README.md](README.md).

## Before you change anything

If `StructChemAIDocs/AGENTS.team.md` exists, read it and follow it first. That's the team's private companion repo. External users won't have it, and everything in this repo must work without it.

## Rules

- **Install nothing on the host** (no `pip install`, `npm -g`, `winget`, browser downloads, or tools that fetch binaries on first run). Every tool runs from an image under `docker/`. Ask before adding or building a new image.
- **This repo is public.** Never copy anything from `StructChemAIDocs/` into public files, commit messages or PR text: data, file names, notes, plans, findings. Private knowledge reaches this repo only by *promotion*, meaning a freshly written public version that a maintainer approves.
- Never commit data, structure, paper or trajectory files, and never bypass the commit guard (`--no-verify`). Run `scripts/setup-workspace.sh` once per clone.
- Run scripts from the repo root. Structure files go in `data/` (`scripts/fetch-pdb.sh <ID>` for public entries). Output goes in `out/`. Both are git-ignored.

## Where things are

- `docker/<tool>/`: one image per tool, with a README.
- `scripts/`: tool wrappers (`pymol-run.sh`, `pymol-cmd.py`), `fetch-pdb.sh`, `setup-workspace.sh`, `hooks/`.
- `docs/runbooks/`: how-to guides. Read [pymol-usage-guide.md](docs/runbooks/pymol-usage-guide.md) before driving PyMOL.
