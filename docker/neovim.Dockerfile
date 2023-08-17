# syntax=docker/dockerfile:1.6
# Use 1.6 buildkit frontend to support:
# * ADD from Git
# * Verifying checksums for ADDed files.

# Build Neovim from source.
FROM debian:bookworm-slim AS neovim-source

RUN apt update 
RUN DEBIAN_FRONTEND=noninteractive \
  apt install --no-install-recommends --assume-yes \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    gettext \
    git \
    unzip

ARG NEOVIM_CHECKSUM=
ARG NEOVIM_SOURCE_URL=https://github.com/neovim/neovim/archive/refs/tags/stable.tar.gz
ARG NEOVIM_VERSION=stable

ADD --checksum=$NEOVIM_CHECKSUM $NEOVIM_SOURCE_URL /src/neovim.tar.gz
RUN tar zxf /src/neovim.tar.gz -C /src/

WORKDIR /src/neovim-$NEOVIM_VERSION
RUN make CMAKE_BUILD_TYPE=RelWithDebInfo && make install

# Copy the Neovim installation to a clean linux image.
FROM debian:bookworm-slim AS neovim

COPY --from=neovim-source /usr/local/bin/nvim /usr/local/bin/nvim
COPY --from=neovim-source /usr/local/lib/nvim /usr/local/lib/nvim
COPY --from=neovim-source /usr/local/share/nvim /usr/local/share/nvim

WORKDIR /root

CMD ["/usr/local/bin/nvim"]
