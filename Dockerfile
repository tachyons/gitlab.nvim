FROM alpine:3.18

WORKDIR /workspace

RUN apk add git neovim

# Install the plenary.vim plugin.
RUN git clone --depth 1 https://github.com/nvim-lua/plenary.nvim ~/.local/share/nvim/site/pack/vendor/start/plenary.nvim

# Install WORKDIR as a vim plugin.
# This can be done through creating a read-only volume mount or extending this image and ADDing plugin files explicitly.
RUN ln -s /workspace ~/.local/share/nvim/site/pack/vendor/start

CMD ["/usr/bin/nvim"]
