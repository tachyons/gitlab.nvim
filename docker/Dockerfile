# syntax=docker/dockerfile:1.6
# Use 1.6 buildkit frontend to support:
# * ADD from Git
# * Verifying checksums for ADDed files.

ARG NEOVIM_IMAGE=registry.gitlab.com/gitlab-org/editor-extensions/gitlab.vim/neovim:stable
# Support remote image tag rather than requiring Neovim be built locally.
FROM $NEOVIM_IMAGE AS neovim

# Copy the Neovim installation to a clean linux image.
FROM debian:bookworm-slim AS playground-neovim

COPY --from=neovim /usr/local/bin/nvim /usr/local/bin/nvim
COPY --from=neovim /usr/local/lib/nvim /usr/local/lib/nvim
COPY --from=neovim /usr/local/share/nvim /usr/local/share/nvim

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install \
      --no-install-recommends --assume-yes \
      ca-certificates \
      curl \
      git \
      jq

WORKDIR /root
ADD lua .config/nvim/lua
ADD init.lua .config/nvim/init.lua

CMD ["/usr/local/bin/nvim"]
