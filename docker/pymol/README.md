# structchem-pymol

Open-source PyMOL 2.5 (Ubuntu 22.04, software OpenGL) in Docker. **Team rule: never install tools on the host OS.**

## Prerequisites

- Docker Desktop running (WSL2 backend), Windows 11 (for WSLg GUI windows).
- Shell: Git Bash or a WSL shell. Run everything from the **repo root**.

## Build

```sh
docker build -t structchem-pymol docker/pymol
```

The image is ~540 MB. Ubuntu 24.04 is deliberately not used: its PyMOL 2.5 package fails on Python 3.12 (`No module named 'imp'`).

## Run

`scripts/pymol-run.sh` mounts the repo at `/work` and, unless `-c` is given, wires the window through WSLg (sockets at `/run/desktop/mnt/host/wslg` inside Docker Desktop's VM).

Structure files go in the git-ignored `data/`. Fetch public entries with `scripts/fetch-pdb.sh 1TUB 6DPU`. Usage guide: [docs/runbooks/pymol-usage-guide.md](../../docs/runbooks/pymol-usage-guide.md).

```sh
# GUI window on the Windows desktop
scripts/pymol-run.sh scripts/pymol/view_1tub.pml
scripts/pymol-run.sh data/6DPU.pdb

# Headless (agents): render a PNG into out/ and exit
scripts/pymol-run.sh -cq scripts/pymol/view_1tub.pml \
  -d "png out/1tub_overview.png, width=1600, height=1200, dpi=150, ray=1"
```

`out/` is created automatically. Files are written as uid 1000.

## Remote control of the GUI (agents and scripts)

GUI mode starts PyMOL with its XML-RPC server (`-R`) in a container named `structchem-pymol-gui`, published at **`127.0.0.1:9123` only**. Drive the live window from the host with `scripts/pymol-cmd.py` (standard-library Python, nothing to install):

```sh
python scripts/pymol-cmd.py ping                          # 1 if the server is up
python scripts/pymol-cmd.py do "turn y, 90"               # any PyMOL command(s), ';'-separated
python scripts/pymol-cmd.py run scripts/pymol/view_1tub.pml
python scripts/pymol-cmd.py call get_names                # call any pymol.cmd function, get the result back
python scripts/pymol-cmd.py call count_atoms '"chain B"'  # args parse as JSON when they can
python scripts/pymol-cmd.py png out/live.png 1600 1200    # ray-traced snapshot of what's on screen
python scripts/pymol-cmd.py view                          # current camera (cmd.get_view)
```

- The human and the agent share **one window**. Whatever the agent does, the human sees live, and the human's mouse moves change what the agent's next `png` captures.
- `do` returns no text (PyMOL's log goes to the container's stdout). Use `call` when you need a value back.
- **Security:** the RPC server exposes the whole `cmd` API, including `cmd.system`, so it can run shell commands inside the container. It is bound to loopback on purpose. Never publish it on `0.0.0.0` on the host.
- One GUI at a time (fixed name and port). Override with `STRUCTCHEM_PYMOL_NAME` and `STRUCTCHEM_PYMOL_RPC_PORT`, and point the client at it with `STRUCTCHEM_PYMOL_RPC=http://127.0.0.1:<port>`.
- Stop it: close the window, or `docker stop structchem-pymol-gui`.

Overrides: `STRUCTCHEM_PYMOL_IMAGE` (image tag) and `STRUCTCHEM_WSLG_DIR` (WSLg dir; use `/mnt/wslg` if calling Docker from inside a WSL distro with its own engine).

## Troubleshooting

| Symptom | Fix |
|---|---|
| `cannot connect to the Docker daemon` | Start Docker Desktop |
| No window appears (GUI mode) | Check WSLg works: `wsl -d Ubuntu-24.04 -- ls /mnt/wslg/.X11-unix` should list `X0`. Run `wsl --update` from an admin prompt if not |
| Paths like `C:/Program Files/Git/work` in errors | Run via `scripts/pymol-run.sh` (it sets `MSYS_NO_PATHCONV=1`) |
| Blank headless PNG | Include `ray=1` in the `png` command |
| `Conflict. The container name "/structchem-pymol-gui" is already in use` | A GUI is already running. Use it, or `docker stop structchem-pymol-gui` |
| `No PyMOL RPC server at …` | The GUI isn't running, or is still starting (give it a few seconds) |
