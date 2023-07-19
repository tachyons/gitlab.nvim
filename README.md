# GitLab Plugin for Neovim

A GitLab Neovim plugin including support [Code Suggestions](#code-suggestions).

## Usage

### Getting started

1. Install the [latest Neovim release](https://github.com/neovim/neovim/releases/latest)

    - For macOS, this can be achieved by running `brew install neovim`

1. Clone this repository into `~/.local/share/nvim/site/pack/gitlab/start/gitlab.vim`

    ```sh
    git clone git@gitlab.com:gitlab-org/editor-extensions/gitlab.vim.git ~/.local/share/nvim/site/pack/gitlab/start/gitlab.vim
    ```

#### Completion

To enable completion using Code Suggestions:

1. Follow the steps to enable [Code Suggestions (Beta)](https://docs.gitlab.com/ee/user/project/repository/code_suggestions.html) for your GitLab instance (SaaS or self-managed).

1. Run [`:GitLabBootstrapCodeSuggestions`](#cmd-GitLabBootstrapCodeSuggestions) to:
   1. Install the latest [language server](http://gitlab.com/gitlab-org/editor-extensions/experiments/gitlab-code-suggestions-language-server-experiment) release.
   1. Register your personal access token with the language server.
   1. Enable Omni completion via Neovim's builtin LSP support.

1. Override `gitlab.options.code_suggestions.auto_filetypes` to configure automatic startup of the Code Suggestions LSP client.

### Commands

| Name | Description |
|------|-------------|
| GitLabBootstrapCodeSuggestions <a id="cmd-GitLabBootstrapCodeSuggestions">🔗</a>| <ol>Installs the LSP server for GitLab Code Suggestions.</li><li>Prompts for a [Personal Access Token][] to connect with the Code Suggestions API.</li></ol> |
| GitLabCodeSuggestionsStart | Starts the Code Suggestions LSP client. |
| GitLabCodeSuggestionsStop | Stops the Code Suggestions LSP client. |

### Configuration

You can configure the plugin through options documented below:

```lua
require('gitlab').setup{
  code_suggestions = {
    -- Disable Code Suggestions functionality.
    enabled = false
  }
}
```

To disable eager loading/setup of the plugin add the following to your `init.lua`:

```lua
-- Disable eager loading of all GitLab plugin files.
vim.g.gitlab_autoload = false
```

#### Global Options

The following global [options](https://neovim.io/doc/user/options.html) are available:

| Option                 | Default | Description                                                                            |
|------------------------|---------|----------------------------------------------------------------------------------------|
| `gitlab_autoload`      | `nil`   | Set to `false` to prevent requiring files nested under `plugin/gitlab/` automatically. |
| `gitlab_plugin_loaded` | `nil`   | Whether the plugin should be loaded (set to `true` when loaded).                       |

#### Init options

Init options can be passed to the `gitlab.setup` function under the appropriate namespace.

| Namespace              | Option                | Default | Description                                                                          |
|------------------------|-----------------------|---------|--------------------------------------------------------------------------------------|
| `code_suggestions` | `auto_filetypes`          | `{ 'python', 'ruby', ..., }`         | A list of different filetypes to enable the builtin Neovim omnifunc completion for. |
| `code_suggestions` | `enabled`                 | `true`                               | Whether to enable Code Suggestions via the LSP binary. |
| `code_suggestions` | `language_server_version` | `nil`                                | The release tag of the language server for use in `GitLabBootstrapCodeSuggestions`. |
| `code_suggestions` | `lsp_binary_path`         | `vim.env.GITLAB_VIM_LSP_BINARY_PATH` | The path where the language server binary is available or should be installed to. |

#### Environment variables

| Name                 | Value                    | Purpose |
|----------------------|--------------------------|---------|
| `GITLAB_VIM_DEBUG`   | `0` or `1` (default `0`) | Enable debugging output into `/tmp/gitlab.vim.log` |
| `GITLAB_VIM_LOGGING` | `0` or `1` (default `1`) | Enable logging output into `/tmp/gitlab.vim.log` |

## Development

1. Install `git` to clone plenary and this project.
2. Install `neovim`.
3. Clone plenary.vim through your plugin manager of choice:

   - Manual installation:

     ```sh
     git clone --depth 1 https://github.com/nvim-lua/plenary.nvim ~/.local/share/nvim/site/pack/vendor/start/plenary.nvim
     ```

4. Depending on your `~/.config/nvim/init.lua`, you may need to comment out some config as it can cause issues.
5. Use [`plenary.test_harness`](https://github.com/nvim-lua/plenary.nvim#plenarytest_harness) to run tests:

   - Inside of Neovim:

     ```sh
     :PlenaryBustedDirectory spec/
     :PlenaryBustedFile spec/gitlab/code_suggestions_spec.lua
     ```

   - To run tests headlessly:

     ```sh
     nvim --headless -c "PlenaryBustedDirectory spec" -c cquit
     ```

## Support

Tell people where they can go to for help. It can be any combination of an issue tracker, a chat room, an email address, etc.

## Roadmap

If you have ideas for releases in the future, it is a good idea to list them in the README.

## Contributing

Everyone can contribute. Consider linting and testing your code locally to save yourself and maintainer's time.

## Authors and acknowledgment

- @erran
- @ashmckenzie

## License

See [LICENSE](./LICENSE).

## Project status

If you have run out of energy or time for your project, put a note at the top of the README saying that development has slowed down or stopped completely. Someone may choose to fork your project or volunteer to step in as a maintainer or owner, allowing your project to keep going. You can also make an explicit request for maintainers.

[Personal Access Token]: https://docs.gitlab.com/ee/user/project/repository/code_suggestions.html#enable-code-suggestions-in-your-gitlab-saas-account "Enable Code Suggestions with a Personal Access Token"
