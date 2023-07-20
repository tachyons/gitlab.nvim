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

#### Completion<a name="module-code_suggestions"></a>

The `gitlab.code_suggestions` module supports:

1. Installation of the GitLab Code Suggestions [language server][] LSP implementation.
1. Configuration of `autocmd` LSP implementation.

Set [`code_suggestions.enabled`](#opt-code_suggestions_enabled)

> I'm using zero-lsp to configure lsp.
> Adding the GitLab plugin will bypass it for the GitLab specific code suggestion.

gitlab.options.code_suggestions.auto_filetypes
gitlab.options.code_suggestions.enabled
> It's invoking our LSP server binary through Neovim's builtin LSP integration.

When using the builtin Omni completion it is recommended to leave `gitlab.options.code_suggestions.fix_newlines` set to `true` (default) to resolve issues with multiline completion.

To enable completion using Code Suggestions:

1. Follow the steps to enable [Code Suggestions (Beta)](https://docs.gitlab.com/ee/user/project/repository/code_suggestions.html) for your GitLab instance (SaaS or self-managed).

1. Run [`:GitLabBootstrapCodeSuggestions`](#cmd-GitLabBootstrapCodeSuggestions) to:
   1. Install the latest GitLab language server release.
   1. Register your personal access token with the GitLab language server.
   1. Enable Omni completion via Neovim's builtin LSP support.

1. Override `gitlab.options.code_suggestions.auto_filetypes` to configure automatic startup of the Code Suggestions LSP client.

### Commands

| Name | Description |
|------|-------------|
| GitLabBootstrapCodeSuggestions <a name="cmd-GitLabBootstrapCodeSuggestions"></a>| <ol><li>Installs the LSP server for GitLab Code Suggestions.</li><li>Prompts for a [Personal Access Token][] to connect with the Code Suggestions API.</li></ol> |
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

[language server]: http://gitlab.com/gitlab-org/editor-extensions/experiments/gitlab-code-suggestions-language-server-experiment "GitLab Code Suggestions language server"
[Personal Access Token]: https://docs.gitlab.com/ee/user/project/repository/code_suggestions.html#enable-code-suggestions-in-your-gitlab-saas-account "Enable Code Suggestions with a Personal Access Token"
