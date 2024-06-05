# GitLab Plugin for Neovim

[[_TOC_]]

A Lua based plugin for Neovim that offers
[GitLab Duo Code Suggestions](https://docs.gitlab.com/ee/user/project/repository/code_suggestions/index.html).

Submit your feedback in the
[(Feedback) GitLab for Neovim](https://gitlab.com/gitlab-org/editor-extensions/gitlab.vim/-/issues/22) issue.

If you're interested in contributing check out the
[development process](docs/developer/development-process.md).

## Requirements

This plugin requires:

- GitLab version 16.1 or later for both SaaS and self-managed.
  While many extension features might work with earlier versions, they are unsupported.
  - The GitLab Duo Code Suggestions feature requires GitLab version 16.8 or later.
- [Neovim](https://neovim.io/) version 0.9 or later.

## Setup

1. Follow the [installation](#install) steps for your chosen plugin manager.
1. Optional. [Configure GitLab Duo Code Suggestions](#omni-completion) as an Omni completion provider.
1. Set up helptags using `:helptags ALL` for access to [`:help gitlab.txt`](doc/gitlab.txt).

## Install

### Without a plugin manager

Run this command to include this project with
[packadd](https://neovim.io/doc/user/repeat.html#%3Apackadd) on startup:

```shell
git clone git@gitlab.com:gitlab-org/editor-extensions/gitlab.vim.git ~/.local/share/nvim/site/pack/gitlab/start/gitlab.vim
```

### lazy.nvim

Add this plugin to your [lazy.nvim](https://github.com/folke/lazy.nvim) configuration:

```lua
{
  'git@gitlab.com:gitlab-org/editor-extensions/gitlab.vim.git',
  -- Activate when a file is created/opened
  event = { 'BufReadPre', 'BufNewFile' },
  -- Activate when a supported filetype is open
  ft = { 'go', 'javascript', 'python', 'ruby' },
  cond = function()
    -- Only activate if token is present in environment variable.
    -- Remove this line to use the interactive workflow.
    return vim.env.GITLAB_TOKEN ~= nil and vim.env.GITLAB_TOKEN ~= ''
  end,
  opts = {
    statusline = {
      -- Hook into the built-in statusline to indicate the status
      -- of the GitLab Duo Code Suggestions integration
      enabled = true,
    },
  },
}
```

### packer.nvim

Declare the plugin in your [packer.nvim](https://github.com/wbthomason/packer.nvim) configuration:

```lua
use {
  "git@gitlab.com:gitlab-org/editor-extensions/gitlab.vim.git",
}
```

## Uninstall

1. Remove this plugin and any language server binaries with these commands:

   ```shell
   rm -r ~/.local/share/nvim/site/pack/gitlab/start/gitlab.vim
   rm ~/.local/share/nvim/gitlab-code-suggestions-language-server-*
   ```

### Configuration

These environment variables are the most frequently used.
For a full list, see this plugin's help text at [`doc/gitlab.txt`](doc/gitlab.txt).

| Environment variable | Default              | Description |
|----------------------|----------------------|-------------|
| `GITLAB_TOKEN`.      | n/a                  | The default GitLab Personal Access Token to use for authenticated requests. If provided, interactive authentication is skipped. |
| `GITLAB_VIM_URL`.    | `https://gitlab.com` | Override the GitLab instance to connect with. Defaults to `https://gitlab.com`. |

### Omni completion

To enable [omni completion](https://neovim.io/doc/user/insert.html#compl-omni-filetypes)
using GitLab Duo Code Suggestions:

1. Create a [Personal Access Token](https://gitlab.com/-/user_settings/personal_access_tokens) with the `api` scope.

1. Install the GitLab Duo Code Suggestions
   [language server](https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp).

   You might find it helpful to configure omni completion's popup menu even for a single suggestion:

   ```lua
   vim.o.completeopt = 'menu,menuone'
   ```

1. When working in a supported file type, use <kbd>Ctrl</kbd> + <kbd>X</kbd>
   then <kbd>Ctrl</kbd> + <kbd>O</kbd> to open the Omni completion menu.

### Keymaps

| Mode     | Keymaps                               | Type     | Description                                                                        |
| -------- | ------------------------------------- | -------- | ---------------------------------------------------------------------------------- |
| `INSERT` | `<C-X><C-O>`                          | Builtin  | Requests completions from GitLab Duo Code Suggestions through the language server. |
| `NORMAL` | `<Plug>(GitLabToggleCodeSuggestions)` | `<Plug>` | Toggles Code Suggestions on/off for the current buffer.                            |

1. Builtin keymaps extend existing features. For example, because Code Suggestions
   provides a LSP server, the built-in `ctrl-x ctrl-o` omni complete keymap works.
1. `<Plug>` keymaps are provided for convenience.

To use `<Plug>(GitLab...)` maps above you must include your own keymap that references it:

```lua
-- Toggle Code Suggestions on/off with CTRL-g in normal mode:
vim.keymap.set('n', '<C-g>', '<Plug>(GitLabToggleCodeSuggestions)')
```

### Resource editing

Enable the `gitlab.resource_editing` to enable:

1. Use `:edit https://gitlab.com/RESOURCE_URL` to open a buffer with the
   description of an epic, issue, or merge request.
1. Saving the buffer with `:w` will update the resource's Markdown description.

### Statusline

`gitlab.statusline` is enabled by default. It hooks into the built-in `statusline`
to show the status of the GitLab Duo Code Suggestions integration.

```lua
require('gitlab').setup({
  statusline = {
    enabled = false
  }
})
```

## Features

### GitLab Duo Code Suggestions

Write code more efficiently by using generative AI to suggest code while you're
developing. To learn more about this feature, see the
[GitLab Duo Code Suggestions documentation](https://docs.gitlab.com/ee/user/project/repository/code_suggestions/index.html)

GitLab Duo Code Suggestions is a generative artificial intelligence (AI) model.
GitLab currently leverages [Google Cloud's Vertex AI Codey API models](https://cloud.google.com/vertex-ai/generative-ai/docs/code/code-models-overview)

No new additional data is collected to enable this feature. Private non-public
GitLab customer data is not used as training data. Learn more about
[Google Vertex AI Codey APIs Data Governance](https://cloud.google.com/vertex-ai/generative-ai/docs/data-governance)

#### Supported languages

For the languages supported by GitLab Duo Code Suggestions, see
[Supported extensions and languages](https://docs.gitlab.com/ee/user/project/repository/code_suggestions/supported_extensions.html)
in the GitLab documentation.

For your convenience, this plugin provides Vim auto-commands to start the
LSP integration for some supported file types. For example, Ruby is a supported
language, so the plugin adds a `FileType ruby` auto-command.

You can configure this behavior for additional file types with the
`code_suggestions.auto_filetypes` setup option.

## Release process

1. Review whether each merge request after the last release has (or requires) a changelog entry.
1. Create a new merge request to increment the plugin version.

   1. Update `PLUGIN_VERSION` in [`lua/gitlab/globals.lua`](lua/gitlab/globals.lua).
   1. Add a new `## vX.Y.Z` header above the previous [CHANGELOG.md](CHANGELOG.md) entry.

1. After it has been approved, merge the merge request.
1. Create a new signed Git tag off of the `main` branch.

## Issues

Looking to [report an issue](https://gitlab.com/gitlab-org/editor-extensions/gitlab.vim/-/issues)?

## Roadmap

To learn more about this project's team, processes, and plans, see
the [Create:Editor Extensions Group](https://handbook.gitlab.com/handbook/engineering/development/dev/create/editor-extensions/)
page in the GitLab handbook.

For a list of all open issues in this project, see the
[issues page](https://gitlab.com/gitlab-org/editor-extensions/gitlab.vim/-/issues)
for this project.

## Contributing

This extension is open source and
[hosted on GitLab](https://gitlab.com/gitlab-org/editor-extensions/gitlab.vim).
Contributions are more than welcome. Feel free to fork and add new features or
submit bug reports. See [CONTRIBUTING](CONTRIBUTING.md) for more information.

[A list of the great people](CONTRIBUTORS.md) who contributed this project, and
made it even more awesome, is available. Thank you all! 🎉

## Troubleshooting

For help troubleshooting, see the [troubleshooting guide](docs/developer/troubleshooting.md).

## License

See [LICENSE](LICENSE).
