# StructChem PyMOL image: open-source PyMOL 2.5 on Ubuntu 22.04.
# (Not 24.04: its PyMOL 2.5 package imports `imp`, which Python 3.12 removed, so it won't start.)
# Team rule: tools live in images, never on the host OS.
#
# Build (from repo root):  docker build -t structchem-pymol docker/pymol
# Run:                     see docker/pymol/README.md

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    # Software OpenGL (Mesa llvmpipe): works under WSLg and with no display at all
    LIBGL_ALWAYS_SOFTWARE=1 \
    QT_X11_NO_MITSHM=1

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      pymol \
      python3-pymol \
      libgl1-mesa-dri \
      fonts-dejavu-core \
 && rm -rf /var/lib/apt/lists/*

# Non-root user so files written into the mounted repo aren't owned by root
RUN useradd -m -u 1000 -s /bin/bash structchem
USER 1000
WORKDIR /work

ENTRYPOINT ["pymol"]
CMD ["-h"]
