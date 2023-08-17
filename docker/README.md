# gitlab.vim Docker images

This directory contains Neovim reference configurations which are compatible with the `gitlab.vim` plugin.
It also includes language server installation methods.

## Quickstart

Use the `registry.gitlab.com/gitlab-org/editor-extensions/gitlab.vim/playground-neovim:latest` image to open the latest stable Neovim using `packadd` to install the `gitlab.vim` plugin manager.

```bash
docker run --rm -it registry.gitlab.com/gitlab-org/editor-extensions/gitlab.vim/playground-neovim:latest
```

Refer to the [usage](#usage) steps below for a breakdown of how to run the image.

## Building

Use `docker build ./docker` to build with this directory's contents as the docker build context.

```bash
# Include the registry image name tag so local test runs will use your local container image.
docker build -t registry.gitlab.com/gitlab-org/editor-extensions/gitlab.vim/playground-neovim:latest ./docker
```

[neovim.Dockerfile](./neovim.Dockerfile) provides the `neovim` image:
1. Installs Neovim's build dependencies.
2. Builds the latest Neovim [stable](https://github.com/neovim/neovim/releases/stable) version.
3. Sets `nvim` as the default command when the image is used.

[Dockerfile](./Dockerfile) provides the `playground-neovim` image:
1. Extends the `neovim.Dockerfile` build.
1. Installs the stable Neovim version built by `neovim.Dockerfile`.
2. Installs gitlab.vim's requirements.
3. Adds [init.lua](./init.lua) to configure Neovim.
4. Sets `nvim` as the default command when the image is used.

## Usage

You can pass environment variables or volume mounts at runtime to configure startup:

```bash
docker run --rm -it \
           -v "$HOME/.local/share/nvim/site/pack/gitlab/start/gitlab.vim:/root/.local/share/nvim/site/pack/gitlab/start/gitlab.vim:ro" \
           -e PLUGIN_MANAGER=packadd \
           registry.gitlab.com/gitlab-org/editor-extensions/gitlab.vim/playground-neovim:latest
```

### Plugin installation

Use the `PLUGIN_MANAGER` environment variable as follows:

| Value          | Installation method                                          |
|----------------|--------------------------------------------------------------|
| `packadd`      | [packadd](https://neovim.io/doc/user/repeat.html#%3Apackadd) |
| `packer`       | [packer.nvim](https://github.com/wbthomason/packer.nvim)     |
| `lazy`         | [lazy.nvim](https://github.com/folke/lazy.nvim)              |

### LSP server installation

Use the `LSP_INSTALLER` environment variable as follows:

| Value              | Installation method                                                               |
|--------------------|-----------------------------------------------------------------------------------|
| `gitlab.vim`       | Invoke the `:GitLabBoostrapCodeSuggestions` command.                              |
| `manual` (default) | Expect the user who starts the container to manually install the language server. |
