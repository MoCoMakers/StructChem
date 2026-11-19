# PyMOL usage guide (for people and agents)

PyMOL is a scriptable 3D molecular viewer. This guide covers opening structure files, selecting and colouring tubulin, and producing images without a GUI so an agent can hand them back.

## 1. Which PyMOL

StructChem uses **open-source PyMOL** (BSD-like licence, free including commercial use), built into the `structchem-pymol` Docker image ([docker/pymol/README.md](../../docker/pymol/README.md)). Nothing is installed on the host. Incentive PyMOL (Schrödinger, commercial) isn't used.

Every `pymol …` command below runs **inside that container**, with the repo mounted at `/work`. `scripts/pymol-run.sh` does this for you.

## 2. Getting a structure

```sh
scripts/fetch-pdb.sh 1TUB      # → data/1TUB.pdb (git-ignored)
```

Prefer files in `data/` over PyMOL's own `fetch`, so a run uses exactly the file you inspected.

## 3. Launching

Run from the **repo root** so relative paths like `data/1TUB.pdb` resolve.

| Goal | Command |
|---|---|
| Open the GUI with a file | `scripts/pymol-run.sh data/1TUB.pdb` |
| Run the 1TUB overview script in the GUI | `scripts/pymol-run.sh scripts/pymol/view_1tub.pml` |
| **Headless**: run a script, write an image, quit | `scripts/pymol-run.sh -cq scripts/pymol/view_1tub.pml -d "png out/1tub.png, width=1600, height=1200, dpi=150, ray=1"` |

Flags: `-c` no GUI (batch), `-q` quiet, `-d "<cmds>"` runs commands after loading. `.pml` files are PyMOL command scripts. `.py` files run as Python with `cmd` available.

**Two agent modes:**

- **Headless** (`-cq` + `png ... ray=1`): for batch jobs and reproducible figures. Return the image path.
- **Live remote control**: when a person is looking at the GUI, drive *their* window with `python scripts/pymol-cmd.py do "<commands>"`, get values back with `call <cmd-function> [args]`, and take snapshots with `png out/<name>.png`. See [remote control](../../docker/pymol/README.md#remote-control-of-the-gui-agents-and-scripts). Prefer a few targeted commands over re-running whole scripts, so the person keeps their place.

## 4. Core commands

```
load data/1TUB.pdb, tub          # load file as object "tub"
hide everything                  # clear all representations
show cartoon, tub                # representations: cartoon, sticks, spheres, surface, lines, ribbon
color wheat, chain B             # colour a selection
spectrum count, rainbow, chain A and name CA   # N-to-C colour gradient
select site, chain B and resi 251    # name a selection
zoom site, 8                     # centre on it with an 8 Å margin
orient tub                       # good overall view
label site and name CA, resn+resi
distance d1, sel1, sel2          # measure (Å)
bg_color white
png out/view.png, width=1600, height=1200, dpi=150, ray=1
save out/view.pse                # whole session (reopen with: pymol out/view.pse)
get_fasta chain B                # print sequence
```

### Selection language

| Want | Selection |
|---|---|
| A chain | `chain A` |
| Residue range | `chain B and resi 240-260` |
| Residue type | `resn ASP` |
| Ligands only | `organic` or `hetatm and not solvent` |
| Protein only | `polymer.protein` |
| Atoms within 5 Å of a ligand | `byres (polymer.protein within 5 of resn TXL)` |
| Combine | `and`, `or`, `not`, parentheses |

## 5. Example: 1TUB, the α/β-tubulin dimer

- Public entry, pig brain tubulin, electron diffraction of zinc-induced sheets (1997). Good for viewing and teaching. Not a microtubule lattice.
- **Chain A = α-tubulin, chain B = β-tubulin.** Ligands: `GTP` on α, `GDP` on β, `TXL` (taxol) on β.
- `scripts/pymol/view_1tub.pml` colours α light blue and β wheat, shows ligands as sticks, and marks one β residue in red.

> **Residue numbering trap.** Many tubulin PDB entries number β-tubulin with the α-tubulin-based scheme, which differs from UniProt/HGVS numbering by a few residues in places. Never map a variant to a structure by residue number alone: align the sequences first.

## 6. Pitfalls

- **Run from the repo root**, or paths in scripts break.
- `ray=1` matters for headless images. Without it you may get a blank or low-quality frame.
- Surfaces on large assemblies are slow. Use `cartoon` first, and `set surface_quality, 0` if needed.
- `reinitialize` at the top of a script clears leftovers from earlier sessions.
- **Never put `;` in a `.pml` comment.** PyMOL 2.5 splits lines on `;` before stripping comments, so `# show x; hide everything else` runs `hide everything else` and errors.
- **Rotating:** `turn y, 90` rotates the camera about the screen's vertical axis (`x` = horizontal, `z` = toward you). `rotate y, 90, tub` moves the molecule's coordinates instead. Prefer `turn` for views.
