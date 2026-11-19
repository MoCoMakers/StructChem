# view_1tub.pml: overview of the pig alpha/beta tubulin dimer (1TUB)
# GUI:       scripts/pymol-run.sh scripts/pymol/view_1tub.pml
# Headless:  scripts/pymol-run.sh -cq scripts/pymol/view_1tub.pml -d "png out/1tub_overview.png, width=1600, height=1200, dpi=150, ray=1"
# Run from the repo root (PyMOL runs in the structchem-pymol Docker image).

reinitialize
load data/1TUB.pdb, tub

# Show the protein as a cartoon, hide everything else
# (never put ';' in a .pml comment: PyMOL 2.5 splits on it and runs the rest as a command)
hide everything
show cartoon, tub and polymer.protein
set cartoon_transparency, 0.1

# Colour the subunits: alpha = chain A, beta = chain B
color lightblue, tub and chain A
color wheat,     tub and chain B

# Ligands as sticks: GTP (alpha, N-site), GDP (beta, E-site), TXL (beta; recorded as Taxotere/docetaxel)
select nuc,   tub and resn GTP+GDP
select taxol, tub and resn TXL
show sticks, nuc or taxol
color green,   nuc and elem C
color magenta, taxol and elem C

# Highlight the beta residue that corresponds to TUBB4A D249 (the classic H-ABC variant).
# 1TUB numbers beta with the alpha-tubulin scheme: native beta D249 is chain B resi 251 here
# (sequence ...G Q L N A D L R K L...). Verify the alignment before relying on it.
select d249_equiv, tub and chain B and resi 251
show spheres, d249_equiv and not name N+C+O
color red, d249_equiv
label d249_equiv and name CA, "beta D249 (1TUB 251)"
set label_size, 24
set label_font_id, 7
set label_color, black
set label_outline_color, white
set float_labels, 1
set label_position, (0, 6, 15)

bg_color white
set ray_opaque_background, 1
orient tub
deselect
