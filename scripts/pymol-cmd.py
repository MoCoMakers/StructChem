#!/usr/bin/env python3
"""Remote-control a running PyMOL GUI (started with scripts/pymol-run.sh) over XML-RPC.

Python standard library only, so it runs with any Python 3 on the host, nothing to install.

Usage (from the repo root):
  python scripts/pymol-cmd.py ping
  python scripts/pymol-cmd.py do "turn y, 90"              # any PyMOL command line(s), ';'-separated
  python scripts/pymol-cmd.py run scripts/pymol/view_1tub.pml   # run a .pml (path relative to repo root)
  python scripts/pymol-cmd.py png out/view.png [W H]        # ray-traced snapshot of the live view
  python scripts/pymol-cmd.py call count_atoms "chain B"    # call any pymol.cmd function, print result
  python scripts/pymol-cmd.py view                          # print the current view matrix (cmd.get_view)

Env: STRUCTCHEM_PYMOL_RPC (default http://127.0.0.1:9123)

Note: cmd.do() output (PyMOL's text log) goes to the container's stdout, not back to the caller.
Use `call` (e.g. get_names, count_atoms, get_fastastr, get_view) when you need a result back.
"""
import json
import os
import sys
import time
import xmlrpc.client

URL = os.environ.get("STRUCTCHEM_PYMOL_RPC", "http://127.0.0.1:9123")


def proxy():
    return xmlrpc.client.ServerProxy(URL, allow_none=True)


def coerce(arg):
    """Turn CLI strings into ints/floats/lists where they parse as JSON; else keep as string."""
    try:
        return json.loads(arg)
    except ValueError:
        return arg


def main(argv):
    if len(argv) < 2 or argv[1] in ("-h", "--help"):
        print(__doc__)
        return 0
    verb, rest = argv[1], argv[2:]
    p = proxy()
    try:
        if verb == "ping":
            print(p.ping())
        elif verb == "do":
            p.do(" ".join(rest))
        elif verb == "run":
            p.do("@" + rest[0])
        elif verb == "png":
            path = rest[0]
            w = int(rest[1]) if len(rest) > 1 else 1600
            h = int(rest[2]) if len(rest) > 2 else 1200
            os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
            before = os.path.getmtime(path) if os.path.exists(path) else 0
            p.png(path, w, h, 150, 1)
            # png is written inside the container onto the mounted repo, so wait for it to land
            for _ in range(120):
                if os.path.exists(path) and os.path.getmtime(path) > before:
                    break
                time.sleep(0.5)
            print(os.path.abspath(path))
        elif verb == "call":
            print(repr(getattr(p, rest[0])(*[coerce(a) for a in rest[1:]])))
        elif verb == "view":
            print(p.get_view())
        else:
            print(f"unknown verb {verb!r}\n{__doc__}", file=sys.stderr)
            return 2
    except ConnectionRefusedError:
        print(f"No PyMOL RPC server at {URL}. Start the GUI with scripts/pymol-run.sh first.",
              file=sys.stderr)
        return 1
    except xmlrpc.client.Fault as e:
        print(f"PyMOL error: {e.faultString}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
