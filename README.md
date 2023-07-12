# GitLab Plugin for Neovim

A GitLab Neovim plugin including support [Code Suggestions](#code-suggestions).

## Usage

### Getting started

1. Follow the steps to enable [Code Suggestions (Beta)](https://docs.gitlab.com/ee/user/project/repository/code_suggestions.html) for your GitLab instance (SaaS or self-managed)

1. Install the [latest Neovim release](https://github.com/neovim/neovim/releases/latest)

    - For macOS, this can be achieved by running `brew install neovim`

1. Clone this repository into `~/.local/share/nvim/site/pack/gitlab/start/gitlab.vim`

    ```sh
    git clone git@gitlab.com:gitlab-org/editor-extensions/gitlab.vim.git ~/.local/share/nvim/site/pack/gitlab/start/gitlab.vim
    ```

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

To disable eager loading of plugin files add the following to init.lua:

```lua
-- Disable eager loading of all GitLab plugin files.
vim.g.gitlab_autoload = false
```

Now you can load and setup only specific functions as desired:

```lua
-- Require the code_suggestions namespace explicitly.
require('gitlab.code_suggestions').setup{}
```

#### Global Options

The following global [options](https://neovim.io/doc/user/options.html) are available:

| Option                 | Default | Description                                                                            |
|------------------------|---------|----------------------------------------------------------------------------------------|
| `gitlab_autoload`      | `nil`   | Set to `false` to prevent requiring files nested under `plugin/gitlab/` automatically. |
| `gitlab_plugin_loaded` | `nil`   | Whether the plugin should be loaded (set to `true` when loaded).                       |

#### Init options

| Namespace              | Option                  | Default | Description                                                                          |
|------------------------|-------------------------|---------|--------------------------------------------------------------------------------------|
| `code_suggestions`     | `personal_access_token` | `nil`   | A GitLab [Personal Access Token][] to authenicate with the Code Suggestions API.     |

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
