# gitlab.vim Docker images

This directory contains docker build configurations for building and testing the `gitlab.vim` plugin.

Images are built as defined in the [docker.yml CI template](../.gitlab/ci_templates/docker.yml).

## `registry.gitlab.com/gitlab-org/editor-extensions/gitlab.vim`<!-- {{{ -->

A linux image with build and test dependencies installed.

1. The branch pipeline for `main` publishes the `latest` and `neovim-stable` image tags.
2. A scheduled pipeline publishes the `neovim-nightly` image tag.

### Plugin installation<!-- {{{ -->

You can pass environment variables at runtime to configure the [plugin installation](#plugin-installation) or [LSP server installation](#lsp-server-installation).

```bash
docker run --rm -it \
           -v "$HOME/.local/share/nvim/site/pack/gitlab/start/gitlab.vim:/root/.local/share/nvim/site/pack/gitlab/start/gitlab.vim:ro" \
           -e PLUGIN_MANAGER=packadd \
           registry.gitlab.com/gitlab-org/editor-extensions/gitlab.vim:latest
```


Use the `PLUGIN_MANAGER` environment variable as follows:

| Value          | Installation method                                          |
|----------------|--------------------------------------------------------------|
| `packadd`      | [packadd](https://neovim.io/doc/user/repeat.html#%3Apackadd) |
| `packer`       | [packer.nvim](https://github.com/wbthomason/packer.nvim)     |
| `lazy`         | [lazy.nvim](https://github.com/folke/lazy.nvim)              |

<!-- }}} -->

### LSP server installation<!-- {{{ -->

Use the `LSP_INSTALLER` environment variable as follows:

| Value              | Installation method                                                               |
|--------------------|-----------------------------------------------------------------------------------|
| `gitlab.vim`       | Invoke the `:GitLabCodeSuggestionsInstallLanguageServer` command.                 |
| `manual` (default) | Expect the user who starts the container to manually install the language server. |

<!-- }}} -->

<!-- }}} -->

## `registry.gitlab.com/gitlab-org/editor-extensions/gitlab.vim/neovim`<!-- {{{ -->

A linux image including Neovim installed from source.

1. The branch pipeline for `main` includes a manual job `package neovim` which accepts the following CI/CD variables:
   1. `$NEOVIM_SOURCE_URL` - _(required)_ The GitHub archive URL containing the source code for the Neovim version to be built.
   2. `$NEOVIM_VERSION`- _(required)_ The Neovim version to be installed (e.g. `0.9.1`, `nightly`, `stable`).
   3. `$NEOVIM_CHECKSUM` - _(optional)_ The SHA256 checksum use for verifying the Neovim source code archive.
2. A scheduled pipeline builds `latest` and `nightly` image tags.

<!-- }}} -->

<!-- vi: set fdm=marker : -->
