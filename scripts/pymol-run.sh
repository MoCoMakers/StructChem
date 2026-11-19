#!/usr/bin/env bash
# Run PyMOL from the structchem-pymol Docker image with the repo mounted at /work.
# Works from Git Bash on Windows (Docker Desktop) and from a WSL shell.
#
#   scripts/pymol-run.sh scripts/pymol/view_1tub.pml          # GUI window on the Windows desktop (WSLg),
#                                                             # remote-controllable via scripts/pymol-cmd.py
#   scripts/pymol-run.sh -cq scripts/pymol/view_1tub.pml \
#       -d "png out/1tub.png, width=1600, height=1200, dpi=150, ray=1"   # headless (agents)
#
# All paths are relative to the repo root.
set -euo pipefail

IMAGE="${STRUCTCHEM_PYMOL_IMAGE:-structchem-pymol}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Git Bash: give Docker a Windows path and stop MSYS rewriting /container/paths
if command -v cygpath >/dev/null 2>&1; then
  REPO_MOUNT="$(cygpath -m "$REPO_ROOT")"
  export MSYS_NO_PATHCONV=1
else
  REPO_MOUNT="$REPO_ROOT"
fi

# Headless if -c (or a flag bundle containing c, e.g. -cq) is among the args
headless=0
for a in "$@"; do [[ "$a" =~ ^-[a-zA-Z]*c[a-zA-Z]*$ ]] && headless=1; done

args=(--rm -v "$REPO_MOUNT":/work -w /work)

pymol_args=("$@")

if [[ $headless -eq 0 ]]; then
  # WSLg sockets as exposed by Docker Desktop's VM (works from Windows and from WSL)
  WSLG="${STRUCTCHEM_WSLG_DIR:-/run/desktop/mnt/host/wslg}"
  RPC_PORT="${STRUCTCHEM_PYMOL_RPC_PORT:-9123}"
  [[ -t 0 ]] && args+=(-it)
  # Remote control: PyMOL's XML-RPC server (-R), published on the host's loopback only.
  # It exposes the full cmd API (including cmd.system), so never bind it beyond 127.0.0.1.
  # Drive it with scripts/pymol-cmd.py.
  args+=(--name "${STRUCTCHEM_PYMOL_NAME:-structchem-pymol-gui}"
    -p "127.0.0.1:${RPC_PORT}:9123"
    -e PYMOL_RPCHOST=0.0.0.0)
  pymol_args=(-R "${pymol_args[@]}")
  args+=(
    -v "$WSLG/.X11-unix":/tmp/.X11-unix
    -v "$WSLG":/mnt/wslg
    -e DISPLAY=:0
    -e WAYLAND_DISPLAY=wayland-0
    -e XDG_RUNTIME_DIR=/mnt/wslg/runtime-dir
    -e PULSE_SERVER=/mnt/wslg/PulseServer)
fi

mkdir -p "$REPO_ROOT/out"
exec docker run "${args[@]}" "$IMAGE" "${pymol_args[@]}"
